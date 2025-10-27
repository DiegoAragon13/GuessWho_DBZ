import 'package:flutter/material.dart';
import 'dart:async';

/// Card estilizada minimalista para textos narrativos con decisiones integradas
class NarrativeCard extends StatefulWidget {
  final String text;
  final String? characterName;
  final List<DecisionOption>? decisions;
  final Function(int index)? onDecisionMade;
  final double fontSize;
  final int typewriterSpeed; // Milisegundos por carácter

  const NarrativeCard({
    Key? key,
    required this.text,
    this.characterName,
    this.decisions,
    this.onDecisionMade,
    this.fontSize = 16.0,
    this.typewriterSpeed = 30, // 30ms por carácter por defecto
  }) : super(key: key);

  @override
  State<NarrativeCard> createState() => _NarrativeCardState();
}

class _NarrativeCardState extends State<NarrativeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int? _selectedDecision;
  int? _hoveredIndex;

  // Variables para el efecto typewriter
  String _displayedText = '';
  bool _isTypingComplete = false;
  Timer? _typewriterTimer;
  int _currentCharIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _startTypewriter();
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NarrativeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
      _selectedDecision = null;
      _resetTypewriter();
      _startTypewriter();
    }
  }

  void _resetTypewriter() {
    _typewriterTimer?.cancel();
    setState(() {
      _displayedText = '';
      _currentCharIndex = 0;
      _isTypingComplete = false;
    });
  }

  void _startTypewriter() {
    _typewriterTimer?.cancel();

    _typewriterTimer = Timer.periodic(
      Duration(milliseconds: widget.typewriterSpeed),
          (timer) {
        if (_currentCharIndex < widget.text.length) {
          setState(() {
            _currentCharIndex++;
            _displayedText = widget.text.substring(0, _currentCharIndex);
          });
        } else {
          timer.cancel();
          setState(() {
            _isTypingComplete = true;
            _displayedText = widget.text;
          });
        }
      },
    );
  }

  void _skipTypewriter() {
    if (!_isTypingComplete) {
      _typewriterTimer?.cancel();
      setState(() {
        _displayedText = widget.text;
        _currentCharIndex = widget.text.length;
        _isTypingComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _skipTypewriter,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Color(0xFF0a0a0a),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(0xFF1a1a1a),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del personaje/narrador
              if (widget.characterName != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    widget.characterName!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

              // Texto narrativo con efecto typewriter
              Text(
                _displayedText,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.7,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),

              // Cursor parpadeante mientras se escribe
              if (!_isTypingComplete)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: _BlinkingCursor(),
                ),

              // Hint para saltar (solo si está escribiendo)
              if (!_isTypingComplete)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Toca para saltar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.3),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              // Botones de decisión (solo aparecen cuando termina de escribirse)
              if (_isTypingComplete &&
                  widget.decisions != null &&
                  widget.decisions!.isNotEmpty) ...[
                SizedBox(height: 32),
                ...List.generate(widget.decisions!.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < widget.decisions!.length - 1 ? 16 : 0,
                    ),
                    child: _buildDecisionButton(
                      widget.decisions![index],
                      index,
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionButton(DecisionOption decision, int index) {
    final isSelected = _selectedDecision == index;
    final isDisabled = _selectedDecision != null && !isSelected;
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) {
        if (!isDisabled) setState(() => _hoveredIndex = index);
      },
      onExit: (_) {
        setState(() => _hoveredIndex = null);
      },
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
          setState(() => _selectedDecision = index);
          Future.delayed(Duration(milliseconds: 200), () {
            widget.onDecisionMade?.call(index);
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(0xFF1a1a1a)
                : isDisabled
                ? Colors.transparent
                : isHovered
                ? Color(0xFF0f0f0f)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.3)
                  : isDisabled
                  ? Color(0xFF1a1a1a)
                  : isHovered
                  ? Color(0xFF2a2a2a)
                  : Color(0xFF1a1a1a),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  decision.text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.9),
                    height: 1.4,
                    letterSpacing: 0.1,
                  ),
                ),
              ),

              // Icono de flecha o check
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.white.withOpacity(0.7),
                )
              else if (isHovered && !isDisabled)
                Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: Colors.white.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cursor parpadeante para el efecto typewriter
class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: Duration(milliseconds: 530),
      vsync: this,
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _blinkAnimation,
      child: Container(
        width: 8,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// Modelo de datos para decisiones
class DecisionOption {
  final String text;
  final String? impactText;
  final Color? impactColor;
  final IconData? impactIcon;
  final int? timeLimit;

  DecisionOption({
    required this.text,
    this.impactText,
    this.impactColor,
    this.impactIcon,
    this.timeLimit,
  });
}