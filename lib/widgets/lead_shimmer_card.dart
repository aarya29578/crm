import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ClaimedLeadCardShimmer extends StatelessWidget {
  const ClaimedLeadCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white),
          child: _buildShimmerContent(),
        ),
        _buildShimmerScheduleCard(),
      ],
    );
  }

  Widget _buildShimmerContent() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 14, height: 14, color: Colors.white),
                SizedBox(width: 5),
                Expanded(child: Container(height: 12, color: Colors.white)),
                Container(width: 18, height: 18, color: Colors.white),
                SizedBox(width: 5),
                Container(width: 18, height: 18, color: Colors.white),
                SizedBox(width: 5),
                Container(width: 18, height: 18, color: Colors.white),
              ],
            ),
            SizedBox(height: 10),
            Container(width: double.infinity, height: 16, color: Colors.white),
            SizedBox(height: 5),
            Container(width: double.infinity, height: 14, color: Colors.white),
            SizedBox(height: 20),
            Container(width: double.infinity, height: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerScheduleCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200, width: 0.7),
                ),
                height: 45,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200, width: 0.7),
                ),
                height: 45,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200, width: 0.7),
                ),
                height: 45,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200, width: 0.7),
                ),
                height: 45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
