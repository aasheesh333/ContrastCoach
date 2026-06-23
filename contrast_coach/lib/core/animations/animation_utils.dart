import 'dart:math' as math;  
   
 import 'package:flutter/material.dart';  
   
 /// MagicUI-style animation utilities for the app.  
 ///  
 /// These animations use spring-like physics, staggered entrances,  
 /// and purposeful motion to guide users through the contrast therapy flow.  
 class AnimationUtils {  
   AnimationUtils._();  
   
   /// Standard spring curve for general animations  
   static const Curve springCurve = Curves.easeOutBack;  
   
   /// Smooth ease for standard transitions  
   static const Curve smoothCurve = Curves.easeInOutCubic;  
   
   /// Standard page transition duration  
   static const Duration standardDuration = Duration(milliseconds: 400);  
   
   /// Quick micro-interaction duration  
   static const Duration microDuration = Duration(milliseconds: 200);  
   
   /// Breathing circle animation duration  
   static const Duration breathingDuration = Duration(seconds: 4);  
   
   /// Shimmer gradient for loading states  
   static LinearGradient get shimmerGradient => const LinearGradient(  
         colors: [  
           Color(0xFFE0E0E0),  
           Color(0xFFF5F5F5),  
           Color(0xFFE0E0E0),  
         ],  
         stops: [0.0, 0.5, 1.0],  
       );  
   
   /// Create a fade + slide page transition  
   static PageTransitionsBuilder get pageTransition =>  
       const _FadeSlidePageTransitionsBuilder();  
   
   /// Staggered list animation with fade + slide  
   static Widget staggeredListItem({  
     required Widget child,  
     required Animation<double> animation,  
     int index = 0,  
     double delay = 0.05,  
   }) {  
     final start = index * delay;  
     final end = start + 0.5;  
     final curvedAnimation = CurvedAnimation(  
       parent: animation,  
       curve: Interval(start, end, curve: springCurve),  
     );  
     return FadeTransition(  
       opacity: curvedAnimation,  
       child: SlideTransition(  
         position: Tween<Offset>(  
           begin: const Offset(0, 0.2),  
           end: Offset.zero,  
         ).animate(curvedAnimation),  
         child: child,  
       ),  
     );  
   }  
   
   /// Breathing animation for the timer circle  
   static AnimationController createBreathingController(  
     TickerProvider vsync, {  
     Duration? duration,  
   }) {  
     return AnimationController(  
       vsync: vsync,  
       duration: duration ?? breathingDuration,  
     );  
   }  
   
   /// Create a breathing scale animation  
   static Animation<double> breathingAnimation(AnimationController controller) {  
     return TweenSequence<double>([  
       TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1.0),  
       TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1.0),  
     ]).animate(  
       CurvedAnimation(parent: controller, curve: Curves.easeInOutSine),  
     );  
   }  
 }  
   
 /// Custom page transition builder for GoRouter  
 class _FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {  
   const _FadeSlidePageTransitionsBuilder();  
   
   @override  
   Widget buildTransitions<T>(  
     PageRoute<T> route,  
     BuildContext context,  
     Animation<double> animation,  
     Animation<double> secondaryAnimation,  
     Widget child,  
   ) {  
     return FadeTransition(  
       opacity: CurvedAnimation(parent: animation, curve: AnimationUtils.smoothCurve),  
       child: SlideTransition(  
         position: Tween<Offset>(  
           begin: const Offset(0.05, 0),  
           end: Offset.zero,  
         ).animate(CurvedAnimation(parent: animation, curve: AnimationUtils.springCurve)),  
         child: child,  
       ),  
     );  
   }  
 }  
   
 /// Breathing circle widget for the active session timer  
 class BreathingCircle extends StatefulWidget {  
   const BreathingCircle({  
     super.key,  
     required this.child,  
     required this.isActive,  
     this.color,  
     this.size,  
   });  
   
   final Widget child;  
   final bool isActive;  
   final Color? color;  
   final double? size;  
   
   @override  
   State<BreathingCircle> createState() => _BreathingCircleState();  
 }  
   
 class _BreathingCircleState extends State<BreathingCircle>  
     with SingleTickerProviderStateMixin {  
   late AnimationController _controller;  
   late Animation<double> _animation;  
   
   @override  
   void initState() {  
     super.initState();  
     _controller = AnimationUtils.createBreathingController(this);  
     _animation = AnimationUtils.breathingAnimation(_controller);  
     if (widget.isActive) {  
       _controller.repeat();  
     }  
   }  
   
   @override  
   void didUpdateWidget(BreathingCircle oldWidget) {  
     super.didUpdateWidget(oldWidget);  
     if (widget.isActive && !_controller.isAnimating) {  
       _controller.repeat();  
     } else if (!widget.isActive && _controller.isAnimating) {  
       _controller.stop();  
     }  
   }  
   
   @override  
   void dispose() {  
     _controller.dispose();  
     super.dispose();  
   }  
   
   @override  
   Widget build(BuildContext context) {  
     return AnimatedBuilder(  
       animation: _animation,  
       builder: (context, child) {  
         return Transform.scale(  
           scale: _animation.value,  
           child: Container(  
             width: widget.size,  
             height: widget.size,  
             decoration: BoxDecoration(  
               shape: BoxShape.circle,  
               color: widget.color?.withOpacity(0.15) ??  
                   Theme.of(context).colorScheme.primary.withOpacity(0.15),  
             ),  
             child: Center(child: widget.child),  
           ),  
         );  
       },  
     );  
   }  
 }  
   
 /// Shimmer loading widget for skeleton screens  
 class ShimmerLoading extends StatefulWidget {  
   const ShimmerLoading({  
     super.key,  
     required this.child,  
     this.isLoading = true,  
   });  
   
   final Widget child;  
   final bool isLoading;  
   
   @override  
   State<ShimmerLoading> createState() => _ShimmerLoadingState();  
 }  
   
 class _ShimmerLoadingState extends State<ShimmerLoading>  
     with SingleTickerProviderStateMixin {  
   late AnimationController _controller;  
   
   @override  
   void initState() {  
     super.initState();  
     _controller = AnimationController(  
       vsync: this,  
       duration: const Duration(milliseconds: 1500),  
     );  
     if (widget.isLoading) {  
       _controller.repeat();  
     }  
   }  
   
   @override  
   void didUpdateWidget(ShimmerLoading oldWidget) {  
     super.didUpdateWidget(oldWidget);  
     if (widget.isLoading && !_controller.isAnimating) {  
       _controller.repeat();  
     } else if (!widget.isLoading && _controller.isAnimating) {  
       _controller.stop();  
     }  
   }  
   
   @override  
   void dispose() {  
     _controller.dispose();  
     super.dispose();  
   }  
   
   @override  
   Widget build(BuildContext context) {  
     if (!widget.isLoading) return widget.child;  
   
     return AnimatedBuilder(  
       animation: _controller,  
       builder: (context, child) {  
         return ShaderMask(  
           shaderCallback: (bounds) {  
             return AnimationUtils.shimmerGradient.createShader(  
               Rect.fromLTWH(  
                 -bounds.width + (_controller.value * bounds.width * 2),  
                 0,  
                 bounds.width,  
                 bounds.height,  
               ),  
             );  
           },  
           blendMode: BlendMode.srcATop,  
           child: widget.child,  
         );  
       },  
     );  
   }  
 }  
   
 /// Celebration widget that shows confetti particles  
 class CelebrationOverlay extends StatefulWidget {  
   const CelebrationOverlay({  
     super.key,  
     this.duration = const Duration(seconds: 3),  
     this.onComplete,  
   });  
   
   final Duration duration;  
   final VoidCallback? onComplete;  
   
   @override  
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();  
 }  
   
 class _CelebrationOverlayState extends State<CelebrationOverlay>  
     with SingleTickerProviderStateMixin {  
   late AnimationController _controller;  
   final List<_ConfettiParticle> _particles = [];  
   final math.Random _random = math.Random();  
   
   @override  
   void initState() {  
     super.initState();  
     _controller = AnimationController(  
       vsync: this,  
       duration: widget.duration,  
     );  
     _controller.addStatusListener(_onStatusChanged);  
     _generateParticles();  
     _controller.forward();  
   }  
   
   void _onStatusChanged(AnimationStatus status) {  
     if (status == AnimationStatus.completed) {  
       widget.onComplete?.call();  
     }  
   }  
   
   void _generateParticles() {  
     for (int i = 0; i < 50; i++) {  
       _particles.add(_ConfettiParticle(  
         color: _getConfettiColor(i),  
         startX: _random.nextDouble(),  
         startY: -1.0,  
         size: _random.nextDouble() * 8 + 4,  
         speed: _random.nextDouble() * 2 + 1,  
         angle: _random.nextDouble() * math.pi * 2,  
       ));  
     }  
   }  
   
   Color _getConfettiColor(int index) {  
     final colors = [  
       const Color(0xFFFF6B6B),  
       const Color(0xFF4ECDC4),  
       const Color(0xFFFFE66D),  
       const Color(0xFFA8E6CF),  
       const Color(0xFFFFD3B6),  
     ];  
     return colors[index % colors.length];  
   }  
   
   @override  
   void dispose() {  
     _controller.dispose();  
     super.dispose();  
   }  
   
   @override  
   Widget build(BuildContext context) {  
     return AnimatedBuilder(  
       animation: _controller,  
       builder: (context, child) {  
         return Stack(  
           children: _particles.map((particle) {  
             final progress = _controller.value;  
             final x = particle.startX + math.cos(particle.angle) * progress * 0.3;  
             final y = particle.startY + particle.speed * progress + 0.5 * 9.8 * progress * progress;  
             final opacity = progress < 0.8 ? 1.0 : 1.0 - (progress - 0.8) / 0.2;  
               
             return Positioned(  
               left: x * MediaQuery.of(context).size.width,  
               top: y * MediaQuery.of(context).size.height,  
               child: Opacity(  
                 opacity: opacity,  
                 child: Container(  
                   width: particle.size,  
                   height: particle.size,  
                   decoration: BoxDecoration(  
                     color: particle.color,  
                     shape: BoxShape.circle,  
                   ),  
                 ),  
               ),  
             );  
           }).toList(),  
         );  
       },  
     );  
   }  
 }  
   
 class _ConfettiParticle {  
   final Color color;  
   final double startX;  
   final double startY;  
   final double size;  
   final double speed;  
   final double angle;  
   
   _ConfettiParticle({  
     required this.color,  
     required this.startX,  
     required this.startY,  
     required this.size,  
     required this.speed,  
     required this.angle,  
   });  
 }  
