import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/widgets/show_call_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

ClaimedLeadCard(
  context,
  time,
  name,
  phone,
  organization,
  leadAssignedTo,
  campaignName,
  id,
  mail,
  followUpDate,
  stageFieldValues,
) {
  return Column(
    children: [
      //Text(id),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white),
        child: ClaimedLeads(
          context,
          time,
          name,
          phone,
          organization,
          leadAssignedTo,
          campaignName,
          id,
          mail,
          followUpDate,
          stageFieldValues,
        ),
      ),
      // ScheduleCard(),
      Container(
        color: Colors.grey.shade200,
        width: double.infinity,
        child: SizedBox(height: 20),
      ),
    ],
  );
}

// ClaimedLeads(time, name, organization, leadAssignedTo, id, mail) {
//   return Container(
//     padding: EdgeInsets.all(10),
//     decoration: BoxDecoration(color: Colors.white),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.call, size: 14, color: Colors.grey),
//             SizedBox(width: 5),
//             Expanded(
//               child: Text(
//                 time,
//                 style: TextStyle(
//                   color: Colors.grey.shade400,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                   letterSpacing: 0,
//                 ),
//               ),
//             ),

//             // Icon(Icons.local_fire_department, size: 18, color: Colors.grey),
//             // Icon(Icons.local_fire_department, size: 18, color: Colors.grey),
//             // Icon(Icons.local_fire_department, size: 18, color: Colors.grey),
//           ],
//         ),
//         SizedBox(height: 10),
//         if (name != '' || name != null)
//           Text(
//             name ?? 'No name',
//             style: TextStyle(
//               color: const Color.fromARGB(255, 75, 74, 74),
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//         if (mail != '' || mail != null)
//           Text(
//             mail ?? 'No Email Id',
//             style: TextStyle(
//               color: Colors.green,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//         if (organization != '' || organization != null)
//           Text(
//             organization ?? 'no organization',
//             style: TextStyle(
//               color: Colors.grey,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//         SizedBox(height: 20),

//         // Row(
//         //   children: [
//         //     Text("Lead id:", style: greyHeading),
//         //     SizedBox(width: 5),
//         //     Text(id, style: greySmallTitle),
//         //   ],
//         // ),
//         // SizedBox(height: 20),
//         Row(
//           children: [
//             Text("Lead assigned to:", style: greyHeading),
//             SizedBox(width: 5),
//             Text(leadAssignedTo, style: blackSmallTitle),
//           ],
//         ),
//       ],
//     ),
//   );
// }

ClaimedLeads(
  context,
  time,
  name,
  phone,
  organization,
  leadAssignedTo,
  campaignName,
  id,
  mail,
  followUpDate,
  stageFieldValues,
) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with time and status indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade500,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  campaignName ?? 'no Campaign Assign!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),

        if (followUpDate != null && followUpDate != '') ...[
          Builder(
            builder: (context) {
              DateTime? parsedDate;
              if (followUpDate is DateTime) {
                parsedDate = followUpDate;
              } else if (followUpDate is String && followUpDate.isNotEmpty) {
                parsedDate = DateTime.tryParse(followUpDate);
              }

              if (parsedDate == null) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.red.shade800),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "Follow up date: ${DateFormat('dd/MM/yyyy hh:mm a').format(parsedDate.toLocal())}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],

        SizedBox(height: 16),

        // Lead Information Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stageFieldValues != null && stageFieldValues is List && stageFieldValues.isNotEmpty) ...[
              ...stageFieldValues.map<Widget>((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.comment_outlined, size: 14, color: Colors.red.shade700),
                        SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 13, color: Colors.red.shade900),
                              children: [
                                TextSpan(
                                  text: "Stage Remark: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: "${field['value'] ?? 'N/A'}",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 8),
            ],
            // Name with avatar
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 18,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name ?? 'No name',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      if (organization != '' && organization != null)
                        Text(
                          organization ?? 'no organization',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Contact info in a clean layout
            if (mail != '' && mail != null)
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mail ?? 'No Email Id',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Divider
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(vertical: 12),
              color: Colors.grey.shade200,
            ),


            // Assignment section
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Assigned to",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          leadAssignedTo,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () async {
                          showCallAlertDialog(
                            context,
                            'Call ${name ?? ''}',
                            'Are you sure want to call ${phone.toString()}?',
                            () async {
                              print("numberto$phone");
                              await CallHelper.callAndTrack(
                                phone.toString(),
                                id,
                                '',
                              );
                              // Navigator.pop(context);
                            },
                            Colors.blue,
                          );
                        },
                        icon: Icon(Icons.phone, color: Colors.white),
                        label: const Text('Call'),
                      ),
                    ),
                  ),

                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(10),
                  //     border: Border.all(color: Colors.grey.shade300, width: 1),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.tag, size: 10, color: Colors.grey.shade500),
                  //       SizedBox(width: 4),
                  //       Text(
                  //         id,
                  //         style: TextStyle(
                  //           color: Colors.grey.shade700,
                  //           fontSize: 11,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

final blackSmallTitle = TextStyle(
  color: Colors.grey.shade800,
  fontSize: 13,
  fontWeight: FontWeight.w600,
);
