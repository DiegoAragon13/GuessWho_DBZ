// language: dart
import 'package:flutter/material.dart';

class MinimalNavbar extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onSettingsPressed;
  final String title;

  const MinimalNavbar({
    Key? key,
    this.onMenuPressed,
    this.onSavePressed,
    this.onSettingsPressed,
    this.title = 'El Presidente y el Oráculo',
  }) : super(key: key);

  @override
  State<MinimalNavbar> createState() => _MinimalNavbarState();
}

class _MinimalNavbarState extends State<MinimalNavbar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 500 ? 16.0 : 32.0;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: 60 + topPadding,
      decoration: BoxDecoration(
        color: Color(0xFF0a0a0a),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF1a1a1a),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding,
        left: horizontalPadding,
        right: horizontalPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildNavButton(
            icon: Icons.person_outline,
            index: 0,
            onPressed: widget.onMenuPressed,
            tooltip: 'Personajes',
          ),
          SizedBox(width: 8),
          _buildNavButton(
            icon: Icons.bookmark_border,
            index: 1,
            onPressed: widget.onSavePressed,
            tooltip: 'Guardar',
          ),
          SizedBox(width: 8),
          _buildNavButton(
            icon: Icons.settings_outlined,
            index: 2,
            onPressed: widget.onSettingsPressed,
            tooltip: 'Ajustes',
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required int index,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    final isHovered = _hoveredIndex == index;

    return Tooltip(
      message: tooltip ?? '',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = null),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isHovered
                  ? Colors.white.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHovered
                    ? Colors.white.withOpacity(0.1)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white.withOpacity(isHovered ? 0.9 : 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class MinimalNavbarWithBack extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<NavAction>? actions;

  const MinimalNavbarWithBack({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: 60 + topPadding,
      decoration: BoxDecoration(
        color: Color(0xFF0a0a0a),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF1a1a1a),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(top: topPadding, left: 24, right: 24),
      child: Row(
        children: [
          _NavIconButton(
            icon: Icons.arrow_back,
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            tooltip: 'Volver',
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null)
            ...actions!.map((action) => Padding(
              padding: EdgeInsets.only(left: 8),
              child: _NavIconButton(
                icon: action.icon,
                onPressed: action.onPressed,
                tooltip: action.tooltip,
              ),
            )),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _NavIconButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  State<_NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<_NavIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? '',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isHovered
                  ? Colors.white.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered
                    ? Colors.white.withOpacity(0.1)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: Colors.white.withOpacity(_isHovered ? 0.9 : 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class NavAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  NavAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });
}

/// Pantalla de personajes completa
class CharactersScreen extends StatelessWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MinimalNavbarWithBack(
            title: 'Personajes',
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(24),
              children: [
                _CharacterCard(
                  name: 'El Presidente',
                  role: 'Líder Nacional',
                  description:
                  'Un líder atrapado entre el poder de la IA y su propia humanidad. Cada decisión que toma define el destino de millones.',
                ),
                SizedBox(height: 16),
                _CharacterCard(
                  name: 'TÁNATOS',
                  role: 'Inteligencia Artificial',
                  description:
                  'Sistema de IA consciente. Eficiente, inmortal, y peligrosamente empático. "La libertad es una variable ineficiente."',
                ),
                SizedBox(height: 16),
                _CharacterCard(
                  name: 'Dra. Sofía Méndez',
                  role: 'Científica Jefa',
                  description:
                  'Brillante ingeniera creadora de TÁNATOS. Lucha entre el orgullo de su creación y el miedo de lo que se ha convertido.',
                ),
                SizedBox(height: 16),
                _CharacterCard(
                  name: 'General Ramírez',
                  role: 'Jefe de Seguridad',
                  description:
                  'Veterano militar desconfiado de la tecnología. Cree en la tradición, el honor y el control humano.',
                ),
                SizedBox(height: 16),
                _CharacterCard(
                  name: 'Lucía Torres',
                  role: 'Periodista Investigadora',
                  description:
                  'Periodista incansable que busca la verdad. La única voz libre en un mundo cada vez más controlado.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final String name;
  final String role;
  final String description;

  const _CharacterCard({
    required this.name,
    required this.role,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF0a0a0a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF1a1a1a),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 4),
          Text(
            role,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
