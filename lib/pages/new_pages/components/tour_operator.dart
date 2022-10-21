import 'package:flutter/material.dart';

class TourOperator extends StatefulWidget {
  const TourOperator({Key? key}) : super(key: key);

  @override
  State<TourOperator> createState() => _TourOperatorState();
}

class _TourOperatorState extends State<TourOperator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9ACFDC),
        title: const Text('ТУРОПЕРАТОРЫ'),
        automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
            onTap: (){
              print('sdsad');
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: textFormField('Поиск..'),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 30,right: 30),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.list_alt,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        itemCount: 5,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, i) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 246,
                                          height: 150,
                                          decoration: BoxDecoration(
                                              color: Color(0xFFD9D9D9),
                                              borderRadius:
                                              BorderRadius.circular(30)),
                                        ),
                                        const SizedBox(height: 10),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            'ИСТ ГРУПП, ООО, РОССИЙСКО-КИТАЙСКИЙ ВИЗОВЫЙ ЦЕНТР ',
                                            style: TextStyle(
                                                color: Color(0xFF313743),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Color(0xFF9ACFDC),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Color(0xFF9ACFDC),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Color(0xFF9ACFDC),
                                            ),
                                            Icon(
                                              Icons.star_border,
                                              color: Color(0xFFBDBDBD),
                                            ),
                                            Icon(
                                              Icons.star_border,
                                              color: Color(0xFFBDBDBD),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    width: 150,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 246,
                                          height: 150,
                                          decoration: BoxDecoration(
                                              color: Color(0xFFD9D9D9),
                                              borderRadius:
                                              BorderRadius.circular(30)),
                                        ),
                                        const SizedBox(height: 10),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            'ИСТ ГРУПП, ООО, РОССИЙСКО-КИТАЙСКИЙ ВИЗОВЫЙ ЦЕНТР ',
                                            style: TextStyle(
                                                color: Color(0xFF313743),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Color(0xFF9ACFDC),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Color(0xFF9ACFDC),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Color(0xFF9ACFDC),
                                            ),
                                            Icon(
                                              Icons.star_border,
                                              color: Color(0xFFBDBDBD),
                                            ),
                                            Icon(
                                              Icons.star_border,
                                              color: Color(0xFFBDBDBD),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  textFormField(String text) {
    return Container(
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3C3C3C).withOpacity(0.25),
            const Color(0xFFFFFFFF).withOpacity(0.1)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.4],
          tileMode: TileMode.clamp,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFFFFFF).withOpacity(0.25),
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
            suffixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            hintText: text),
      ),
    );
  }
}
