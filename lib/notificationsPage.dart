import 'package:dailyflow/database/notificationDatabase.dart';
import 'package:flutter/material.dart';
import 'package:dailyflow/widgets/navigationBar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>>? _notifications;
  Set<int> openedNotifications = {};

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final notifications = await NotificationDatabase.instance.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = notifications;
      // Update openedNotifications based on database state
      openedNotifications = Set.from(
        notifications.where((n) => n['is_read'] == 1).map((n) => n['id'] as int)
      );
    });
  }

  Future<void> _markAsRead(int id) async {
    await NotificationDatabase.instance.markAsRead(id);
    await _fetchNotifications();
  }

  Future<void> _markAsUnread(int id) async {
    await NotificationDatabase.instance.markAsUnread(id);
    await _fetchNotifications();
  }

  Future<void> _deleteNotification(int id) async {
    await NotificationDatabase.instance.deleteNotification(id);
    await _fetchNotifications();
  }

  void _showNotificationDialog(BuildContext context, Map<String, dynamic> notification) async {
    final id = notification['id'] as int;
    final text = notification['text'] as String;
    final isRead = notification['is_read'] == 1;

    // Mark as read when opened if not already read
    if (!isRead) {
      await _markAsRead(id);
    }

    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Notification'),
          content: SingleChildScrollView(
            child: Text(text),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _markAsUnread(id);
                Navigator.pop(context);
              },
              child: const Text('Mark as Unread'),
            ),
            TextButton(
              onPressed: () {
                _deleteNotification(id);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _notifications == null
          ? const Center(child: CircularProgressIndicator())
          : _notifications!.isEmpty
              ? const Center(child: Text('No notifications'))
              : ListView.builder(
                  itemCount: _notifications!.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications![index];
                    final id = notification['id'] as int;
                    final text = notification['text'] as String;
                    final isRead = notification['is_read'] == 1;

                    return Dismissible(
                      key: Key(id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _deleteNotification(id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isRead ? Colors.grey.shade100 : Colors.blue.shade50,
                          border: Border.all(
                            color: isRead ? Colors.grey.shade300 : Colors.blue.shade200,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isRead 
                                ? Colors.grey.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          leading: Icon(
                            isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                            color: isRead ? Colors.grey.shade400 : Colors.blue.shade700,
                            size: 28,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                text,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isRead ? Colors.grey.shade700 : Colors.black,
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isRead 
                                    ? Colors.grey.shade200 
                                    : Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isRead ? 'Read' : 'New',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isRead 
                                      ? Colors.grey.shade700 
                                      : Colors.blue.shade900,
                                    fontWeight: isRead 
                                      ? FontWeight.normal 
                                      : FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isRead)
                                IconButton(
                                  icon: const Icon(Icons.mark_email_unread_outlined),
                                  color: Colors.grey.shade600,
                                  onPressed: () => _markAsUnread(id),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.grey.shade600,
                                onPressed: () => _deleteNotification(id),
                              ),
                            ],
                          ),
                          onTap: () => _showNotificationDialog(context, notification),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const CustomNavigationBar(
        enabledButtons: [false, false, true, false],
      ),
    );
  }
}