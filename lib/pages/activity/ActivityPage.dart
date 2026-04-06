import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/color_palette.dart';

class ActivityPage extends StatelessWidget {
  ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: _buildTimeline(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: ColorConstants.MainPurpleBackground,
      title: const Text(
        "Activity",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevation: 0,
    );
  }

  Widget _buildTimeline() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: _timelineData.length,
      separatorBuilder: (context, index) {
        if (_timelineData[index].isDateHeader ||
            (index > 0 && _timelineData[index - 1].isDateHeader)) {
          return const SizedBox(height: 16);
        }
        return const SizedBox(height: 8);
      },
      itemBuilder: (context, index) {
        final item = _timelineData[index];
        if (item.isDateHeader) {
          return _buildDateHeader(item.title);
        } else if (item.isNote) {
          return _buildNoteItem(item);
        }
        return _buildTimelineItem(item);
      },
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TimelineItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (item.actionText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.actionText!,
                    style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(TimelineItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Text(
                  item.content!,
                  maxLines: item.hasReadMore ? 2 : null,
                  overflow: item.hasReadMore ? TextOverflow.ellipsis : null,
                  style: const TextStyle(fontSize: 13),
                ),
                if (item.hasReadMore) ...[
                  const SizedBox(height: 4),
                  const Text(
                    "Read More",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  final List<TimelineItem> _timelineData = [
    TimelineItem.dateHeader("9 May '25"),
    TimelineItem(
      icon: Icons.calendar_today_outlined,
      title: "Follow Up planned by Suraj Vishwakarma",
      subtitle: "12:30 pm • Atlanta Customer Data",
      actionText: "View details",
    ),
    TimelineItem.dateHeader("22 Mar '25"),
    TimelineItem.note(
      title: "Note added by Suraj Vishwakarma",
      subtitle: "12:06 pm",
      content:
          "Clinet koparkaine me rahat ha 1 bhk dekh toh rahi ha but abhi ghar pe shaddi ha bola ki 2 mahine baad cal...",
      hasReadMore: true,
    ),
    TimelineItem(
      icon: Icons.call_made_outlined,
      title: "Outgoing Call by Suraj V",
      subtitle: "12:00 pm • 5m 6s • Atlanta Customer Data",
    ),
    TimelineItem(
      icon: Icons.person_outline,
      title: "Claimed by Suraj Vishwakarma",
      subtitle: "11:29 am • Atlanta Customer Data",
    ),
    TimelineItem.dateHeader("21 Mar '25"),
    TimelineItem(
      icon: Icons.send_outlined,
      title: "Sent to Fresh",
      subtitle: "06:19 pm • Atlanta Customer Data",
    ),
    TimelineItem(
      icon: Icons.search,
      title: "Inquired via Google",
      subtitle: "06:17 pm • Atlanta Customer Data",
    ),
    TimelineItem(
      icon: Icons.source_outlined,
      title: "Channel",
      subtitle: "csv-leads-upload",
    ),
  ];
}

class TimelineItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final String? content;
  final bool isDateHeader;
  final bool isNote;
  final bool hasReadMore;

  TimelineItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.content,
    this.isDateHeader = false,
    this.isNote = false,
    this.hasReadMore = false,
  });

  factory TimelineItem.dateHeader(String date) {
    return TimelineItem(
      icon: Icons.calendar_today_outlined,
      title: date,
      subtitle: '',
      isDateHeader: true,
    );
  }

  factory TimelineItem.note({
    required String title,
    required String subtitle,
    required String content,
    bool hasReadMore = false,
  }) {
    return TimelineItem(
      icon: Icons.note_outlined,
      title: title,
      subtitle: subtitle,
      content: content,
      isNote: true,
      hasReadMore: hasReadMore,
    );
  }
}
