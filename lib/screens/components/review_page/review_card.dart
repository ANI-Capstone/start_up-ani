import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/review.dart';
import 'package:ani_capstone/screens/components/widgets/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatefulWidget {
  Review review;
  ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 1.5,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryColor,
                    backgroundImage:
                        NetworkImage(widget.review.reviewer.photoUrl)),
                title: Text(
                  widget.review.reviewer.name,
                  style: const TextStyle(
                      color: linkColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: SizedBox(
                  height: 16,
                  child: RatingBar.builder(
                    initialRating: widget.review.rating,
                    ignoreGestures: true,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    unratedColor: primaryColor.withOpacity(0.7),
                    itemPadding: const EdgeInsets.symmetric(vertical: 5),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemSize: 16,
                    onRatingUpdate: (rating) {
                      null;
                    },
                  ),
                ),
                minVerticalPadding: 0,
              )),
          if (widget.review.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Text(widget.review.description!,
                  style: const TextStyle(color: linkColor, fontSize: 13)),
            ),
          if (widget.review.photos!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 5, bottom: 10),
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  itemCount: widget.review.photos!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImagePreview(
                                    image: widget.review.photos![index]),
                              ));
                        },
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          child: Image.network(
                            widget.review.photos![index],
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, url, error) => const Icon(
                                Icons.error,
                                size: 12,
                                color: linkColor),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
            child: Text(
              DateFormat('MM/dd/yyyy').format(widget.review.postedAt),
              style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
            ),
          )
        ]));
  }
}
