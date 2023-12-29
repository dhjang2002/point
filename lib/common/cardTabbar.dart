import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:point/constant/constant.dart';
import 'package:point/models/kItemGoodsCategory.dart';

class CardTabbar extends StatefulWidget {
  final List<ItemGoodsCategory> items;
  int? index;
  Function(ItemGoodsCategory item)? onChange;
  CardTabbar({
    Key? key,
    required this.items,
    this.index = 0,
    this.onChange,
  }) : super(key: key);

  @override
  State<CardTabbar> createState() => _CardTabbarState();
}

class _CardTabbarState extends State<CardTabbar> {

  int curr_Index = 0;

  @override
  void initState() {
    curr_Index = widget.index!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
          itemBuilder: (context, index){
            ItemGoodsCategory item = widget.items[index];
            return GestureDetector(
                onTap: (){
                  setState(() {
                    curr_Index = index;
                  });
                  if(widget.onChange != null) {
                    widget.onChange!(item);
                  }
                },
                child:Container(
                  padding: EdgeInsets.fromLTRB(1, 5, 1, 5),
                  width: 64,
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0, left: 0, right: 0,
                        child: Center(child:Text(item.sName,
                          style: (index==curr_Index) ? ItemBkB16 : ItemG1N16,
                          overflow: TextOverflow.ellipsis,)),
                      ),

                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(1, 5, 1, 3),
                          height: 2,
                          color: (index==curr_Index) ? Colors.black : Colors.grey[100],
                        ),
                      ),

                    ],
                  ),
                )
            );
          }),
    );
  }
}
