import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_scope.dart';
import '../backup/backup.dart';
import '../l10n/app_localizations.dart';

/// Settings → Backup: the recovery code (copy it) and "Restore from a code".
class BackupSection extends StatefulWidget {
  const BackupSection({super.key});

  @override
  State<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<BackupSection> {
  final _input = TextEditingController();
  bool _loading = true;
  bool _copied = false;
  bool _restoring = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    // Opening Settings saves now, which also makes the code if there is none.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppScope.of(context).backup.sync(force: true);
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final t = AppLocalizations.of(context);
    final backup = AppScope.of(context).backup;
    if (Backup.parse(_input.text) == null) {
      setState(() => _message = t.backupBadCode);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.backupRestoreTitle),
        content: Text(t.backupConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            key: const ValueKey('restore-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.backupYesRestore),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _restoring = true);
    final result = await backup.restore(_input.text);
    if (!mounted) return;
    setState(() {
      _restoring = false;
      _message = switch (result) {
        RestoreResult.done => t.backupDone,
        RestoreResult.badCode => t.backupBadCode,
        RestoreResult.notFound => t.backupNotFound,
        RestoreResult.offline => t.backupOffline,
      };
      if (result == RestoreResult.done) _input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final backup = AppScope.of(context).backup;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: backup,
      builder: (context, _) {
        final key = backup.key;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_done_outlined, color: scheme.primary),
                  const SizedBox(width: 12),
                  Text(t.backupTitle, style: text.titleSmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(t.backupAuto, style: text.bodySmall),
              const SizedBox(height: 12),
              Text(t.backupCodeLabel, style: text.labelLarge),
              const SizedBox(height: 4),
              if (key != null)
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        Backup.format(key),
                        key: const ValueKey('backup-code'),
                        textDirection: TextDirection.ltr,
                        style: text.titleLarge?.copyWith(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      key: const ValueKey('backup-copy'),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: Backup.format(key)),
                        );
                        if (mounted) setState(() => _copied = true);
                      },
                      icon: Icon(_copied ? Icons.check : Icons.copy, size: 18),
                      label: Text(_copied ? t.backupCopied : t.backupCopy),
                    ),
                  ],
                )
              else
                Text(
                  _loading ? t.backupGetting : t.backupOffline,
                  style: text.bodyMedium,
                ),
              const SizedBox(height: 4),
              Text(
                t.backupHelp,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text(t.backupRestoreTitle, style: text.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('restore-input'),
                      controller: _input,
                      textDirection: TextDirection.ltr,
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'XXXX-XXXX-XXXX',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const ValueKey('restore'),
                    onPressed: _restoring ? null : _restore,
                    child: Text(t.backupRestore),
                  ),
                ],
              ),
              if (_message != null) ...[
                const SizedBox(height: 8),
                Text(
                  _message!,
                  key: const ValueKey('restore-message'),
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
