import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/auth_provider.dart';
import '../services/purchase_service.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  final PurchaseService _purchaseService = PurchaseService();

  Offerings? _offerings;
  bool _loadingOfferings = true;
  bool _isPurchasing     = false;
  bool _isAnnualSelected = true; // Anual preseleccionado (mejor valor)

  // Precios de fallback (se muestran si RevenueCat no responde)
  static const String _fallbackMonthly = '4,99 €';
  static const String _fallbackAnnual  = '39,99 €';

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final offerings = await _purchaseService.getOfferings();
    if (!mounted) return;
    setState(() {
      _offerings      = offerings;
      _loadingOfferings = false;
    });
  }

  // ─── Helpers de offering ────────────────────────────────────────────────────

  Package? get _monthlyPackage => _offerings?.current?.monthly;
  Package? get _annualPackage  => _offerings?.current?.annual;
  Package? get _selectedPackage =>
      _isAnnualSelected ? _annualPackage : _monthlyPackage;

  String get _monthlyPrice =>
      _monthlyPackage?.storeProduct.priceString ?? _fallbackMonthly;

  String get _annualPrice =>
      _annualPackage?.storeProduct.priceString ?? _fallbackAnnual;

  // ─── Acciones ───────────────────────────────────────────────────────────────

  Future<void> _purchase() async {
    final package = _selectedPackage;
    if (package == null) {
      _showSnackBar('Los planes no están disponibles en este momento.',
          isError: true);
      return;
    }

    setState(() => _isPurchasing = true);
    final success = await _purchaseService.purchase(package);
    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (success) {
      await context.read<AuthProvider>().refreshPremiumStatus();
      if (!mounted) return;
      Navigator.of(context).pop(true);
      _showSnackBar('¡Bienvenido a Premium! 🎉', isError: false);
    }
    // Si no fue exitoso (cancelado o error), simplemente volvemos al paywall.
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    final success = await _purchaseService.restore();
    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (success) {
      await context.read<AuthProvider>().refreshPremiumStatus();
      if (!mounted) return;
      Navigator.of(context).pop(true);
      _showSnackBar('¡Compras restauradas! 🎉', isError: false);
    } else {
      _showSnackBar('No se encontraron compras previas.', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Contenido scrollable ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildBenefits(),
                    const SizedBox(height: 28),
                    _buildPlanSelector(),
                    const SizedBox(height: 12),
                    _buildTrialNote(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // ── CTA fijo en la parte inferior ───────────────────────────────
            _buildBottomCta(),
          ],
        ),
      ),
    );
  }

  // ─── Secciones de UI ────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        // Icono premium
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 1.5),
          ),
          child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 48),
        ),
        const SizedBox(height: 16),
        const Text(
          'Hipómetro Áureo Premium',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        // Badge de prueba gratuita
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_giftcard, color: Colors.black, size: 16),
              SizedBox(width: 6),
              Text(
                '7 días gratis · Cancela cuando quieras',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    const benefits = [
      (Icons.analytics_outlined,    'Triángulo de fuerza',       'Análisis biomecánico avanzado'),
      (Icons.history_toggle_off,    'Líneas de aplomo',          'Evaluación postural completa'),
      (Icons.all_inclusive_rounded, 'Análisis ilimitados',       'Sin límite mensual de análisis'),
      (Icons.cloud_done_outlined,   'Historial en la nube',      'Guarda y compara todos tus análisis'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Todo lo que incluye Premium',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          ...benefits.map((b) => _BenefitRow(icon: b.$1, title: b.$2, subtitle: b.$3)),
        ],
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Row(
      children: [
        Expanded(
          child: _PlanCard(
            label: 'Mensual',
            price: _monthlyPrice,
            subtext: 'por mes',
            isSelected: !_isAnnualSelected,
            isBestValue: false,
            isLoading: _loadingOfferings,
            onTap: () => setState(() => _isAnnualSelected = false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PlanCard(
            label: 'Anual',
            price: _annualPrice,
            subtext: 'por año',
            savings: 'Ahorra un 33 %',
            isSelected: _isAnnualSelected,
            isBestValue: true,
            isLoading: _loadingOfferings,
            onTap: () => setState(() => _isAnnualSelected = true),
          ),
        ),
      ],
    );
  }

  Widget _buildTrialNote() {
    return Text(
      'El periodo de prueba gratuito de 7 días comienza hoy.\n'
      'Puedes cancelar en cualquier momento desde los ajustes de tu cuenta.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.45),
        fontSize: 11,
        height: 1.6,
      ),
    );
  }

  Widget _buildBottomCta() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón principal
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPurchasing ? null : _purchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.amber[700]!.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isPurchasing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      _isAnnualSelected
                          ? 'Empezar prueba gratis (Anual)'
                          : 'Empezar prueba gratis (Mensual)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          // Restaurar compras
          TextButton(
            onPressed: _isPurchasing ? null : _restore,
            child: Text(
              'Restaurar compras',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String   title;
  final String   subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.amber, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.amber, size: 18),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.label,
    required this.price,
    required this.subtext,
    required this.isSelected,
    required this.isBestValue,
    required this.isLoading,
    required this.onTap,
    this.savings,
  });

  final String   label;
  final String   price;
  final String   subtext;
  final String?  savings;
  final bool     isSelected;
  final bool     isBestValue;
  final bool     isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? Colors.amber : Colors.white.withValues(alpha: 0.15);
    final bgColor     = isSelected
        ? Colors.amber.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.04);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Mejor valor" badge (solo plan anual)
            if (isBestValue)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Mejor valor',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            if (isLoading)
              Container(
                height: 14,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            else ...[
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtext,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              if (savings != null) ...[
                const SizedBox(height: 4),
                Text(
                  savings!,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 6),
            // Radio indicator
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? Colors.amber : Colors.white30,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
