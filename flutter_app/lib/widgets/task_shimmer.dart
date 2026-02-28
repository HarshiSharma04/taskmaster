import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_config.dart';

class TaskShimmer extends StatelessWidget {
  const TaskShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: 6,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Shimmer.fromColors(
          baseColor: AppColors.sand,
          highlightColor: AppColors.cream,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 200,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 34),
                    child: Container(
                      width: 150,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 34),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 70,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
