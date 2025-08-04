import 'package:flutter/material.dart';
import '../models/email_model.dart';

/// Widget for displaying a single email item in a list
class EmailListItem extends StatelessWidget {
  final EmailModel email;
  final VoidCallback? onTap;
  final VoidCallback? onStarred;
  final VoidCallback? onDelete;

  const EmailListItem({super.key, required this.email, this.onTap, this.onStarred, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: email.isRead ? Colors.grey[300] : Theme.of(context).primaryColor,
          child: Text(
            email.fromName.isNotEmpty ? email.fromName[0].toUpperCase() : '?',
            style: TextStyle(color: email.isRead ? Colors.grey[600] : Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                email.fromName.isNotEmpty ? email.fromName : email.from,
                style: TextStyle(fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (email.hasAttachments) Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(_formatTime(email.receivedAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              email.subject,
              style: TextStyle(fontWeight: email.isRead ? FontWeight.normal : FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              email.preview,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildProviderChip(email.provider),
                if (email.isImportant) ...[const SizedBox(width: 4), Icon(Icons.priority_high, size: 16, color: Colors.red[600])],
                if (email.labels.isNotEmpty) ...[const SizedBox(width: 4), Expanded(child: Wrap(spacing: 4, children: email.labels.take(3).map((label) => _buildLabelChip(label)).toList()))],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(email.isStarred ? Icons.star : Icons.star_border, color: email.isStarred ? Colors.amber : Colors.grey, size: 20),
              onPressed: onStarred,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              padding: EdgeInsets.zero,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    onDelete?.call();
                    break;
                  case 'mark_read':
                    // TODO: Implement mark as read
                    break;
                  case 'archive':
                    // TODO: Implement archive
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_read',
                  child: Row(children: [Icon(Icons.mark_email_read), SizedBox(width: 8), Text('Mark as read')]),
                ),
                const PopupMenuItem(
                  value: 'archive',
                  child: Row(children: [Icon(Icons.archive), SizedBox(width: 8), Text('Archive')]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        isThreeLine: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildProviderChip(String provider) {
    final color = provider == 'gmail' ? Colors.red : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        provider.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLabelChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 10)),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
