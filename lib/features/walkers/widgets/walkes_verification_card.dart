import 'package:flutter/material.dart';

class WalkersVerificationCard extends StatelessWidget {
  final bool nameMatched;
  final bool dobMatched;
  final bool aadhaarVerified;

  final ValueChanged<bool> onNameChanged;
  final ValueChanged<bool> onDobChanged;
  final ValueChanged<bool> onAadhaarChanged;

  final VoidCallback onSave;
  final bool saving;

  final Color roleColor;

  const WalkersVerificationCard({
    super.key,
    required this.nameMatched,
    required this.dobMatched,
    required this.aadhaarVerified,
    required this.onNameChanged,
    required this.onDobChanged,
    required this.onAadhaarChanged,
    required this.onSave,
    required this.saving,
    this.roleColor = const Color(0xFFFF6600),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          _check(
            'Name Matched',
            nameMatched,
            onNameChanged,
          ),
          _divider(),

          _check(
            'DOB Matched',
            dobMatched,
            onDobChanged,
          ),
          _divider(),

          _check(
            'Aadhaar Verified',
            aadhaarVerified,
            onAadhaarChanged,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              6,
              14,
              14,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: roleColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize:
                      const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Verification',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _check(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return CheckboxListTile(
      value: value,
      onChanged: (newValue) {
        onChanged(newValue ?? false);
      },
      activeColor: roleColor,
      checkColor: Colors.white,
      controlAffinity:
          ListTileControlAffinity.leading,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: Color(0xFFE5E7EB),
    );
  }
}
