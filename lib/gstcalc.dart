import 'package:flutter/material.dart';

class gstcalculator extends StatefulWidget {
  const gstcalculator({super.key});

  @override
  State<gstcalculator> createState() => _gstcalculatorState();
}

class _gstcalculatorState extends State<gstcalculator> {
  TextEditingController txtamt=TextEditingController();
  TextEditingController txtper=TextEditingController();
  TextEditingController txttotal=TextEditingController();
  var igst=0.0;
  var sgst=0.0;
  var cgst=0.0;
  bool isRev=true;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('GST Calculator'),
        backgroundColor: Colors.amber,

      ),
      body: Column(
        children: [
          SwitchListTile(
            value: isRev,
            onChanged:(v){
            isRev=v;
            setState(() {});
          },
          title: Text('isReversed'),
          ),
          TextField(
            controller: txtamt,
            decoration: InputDecoration(hintText: 'Enter Amount',labelText: "Amount"),
          ),
            TextField(
            controller: txtper,
            decoration: InputDecoration(hintText: 'Enter GST%',labelText: "GST%"),
          ),
          Text('IGST:${igst.toStringAsFixed(2)}'),
          Text('SGST:${sgst.toStringAsFixed(2)}'),
          Text('CGST:${cgst.toStringAsFixed(2)}'),

            TextField(
            controller: txttotal,
            decoration: InputDecoration(hintText: 'Enter total amount',labelText: "Total Amount"),
          ),
         
          ElevatedButton(
            onPressed:(){
              if(isRev){
                  if(txttotal.text.isNotEmpty&&txtper.text.isNotEmpty){
               double amt=double.parse(txttotal.text)/(1+double.parse(txtper.text)*0.01);
                igst=amt+double.parse(txtper.text)*0.01;
                cgst=igst*0.5;
                sgst=igst*0.5;
               txtamt.text = (amt).toStringAsFixed(2);
               
                
              }
              }else{
                  if (txtamt.text.isNotEmpty && txtper.text.isNotEmpty) {
                igst = double.parse(txtamt.text) *
                    double.parse(txtper.text) *
                    0.01;
                cgst = igst * 0.5;
                sgst = igst * 0.5;
                 txttotal.text =(double.parse(txtamt.text) + igst).toString();
              }

              }
            
              setState(() {});
            },
           child:Text('Calculate'),
           ),
    

]),

    );
  }
}