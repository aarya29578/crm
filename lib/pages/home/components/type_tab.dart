import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

Widget buildTab(String text, int index) {
  final HomeController homeController = Get.put(HomeController());

  return GestureDetector(
    onTap: () => homeController.selectedTab.value = index,
    child: Container(
      margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:
            // homeController.selectedTab.value == index
            //     ? Colors.blue
            //     :
            Colors.white,
        boxShadow: [BoxShadow(blurRadius: 0.01)],
        //border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.3,
            fontWeight: FontWeight.w500,
            color:
                // home_controller.selectedTab.value == index
                //     ? Colors.white
                //     :
                Colors.black,
          ),
        ),
      ),
    ),
  );
}

//
class CallCountInfo extends StatelessWidget {
  const CallCountInfo({
    super.key,
    required this.count,
    required this.percentage,
    required this.status,
  });

  final String count;
  final String percentage;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPercentageColor(percentage),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  percentage,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(String percentage) {
    final value = double.tryParse(percentage.replaceAll('%', '')) ?? 0;
    if (value >= 75) {
      return const Color(0xFF4CAF50);
    } else if (value >= 50) {
      return const Color(0xFF2196F3);
    } else {
      return const Color(0xFFF44336);
    }
  }
}

//
class CustomerRangeRow extends StatelessWidget {
  const CustomerRangeRow({
    super.key,
    required this.text,
    required this.percentage,
    required this.count,
    this.color = Colors.blue,
  });

  final String text;
  final double percentage;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressWidth = percentage.clamp(0, 100) / 100;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Label - fixed width
          SizedBox(
            width: 60,
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 12),

          // Progress bar
          Expanded(
            child: Container(
              height: 20,
              child: Stack(
                children: [
                  // Background track
                  Container(
                    width: double.infinity,
                    height: 8,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Progress fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    height: 8,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, Color.lerp(color, Colors.white, 0.2)!],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color,
                              Color.lerp(color, Colors.black, 0.1)!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Percentage and Count
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 12, color: Colors.grey.shade300),
                const SizedBox(width: 8),
                Text(
                  count,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OpenActionTab extends StatelessWidget {
  const OpenActionTab({
    super.key,
    required this.icon,
    required this.count,
    required this.text,
    this.iconColor,
    this.countColor,
    this.textColor,
    this.spacing = 8,
    this.padding = const EdgeInsets.all(16.0),
  });

  final IconData icon;
  final String count;
  final String text;
  final Color? iconColor;
  final Color? countColor;
  final Color? textColor;
  final double spacing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 20),
          SizedBox(width: spacing),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
