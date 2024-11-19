import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class colorScreen extends StatefulWidget {
  const colorScreen({super.key});

  @override
  State<colorScreen> createState() => _colorScreenState();
}

class _colorScreenState extends State<colorScreen> {
  List colors=[Colors.black,Colors.green,Colors.yellow,Colors.red];
  int i=0;
      @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column( 
       
        children: [
          Row(
            children: [
            Expanded(
            child:Container(color:colors[(i)%4],height:100,),
            ),
            Expanded(
            child:Container(color:colors[(i+1)%4],height:100,),
            ),
            Expanded(
            child:Container(color:colors[(i+2)%4],height:100,),
            ),
            Expanded(
            child:Container(color:colors[(i+3)%4],height:100,),
            ),
          
            ]
             

          ),
              Row(
            children: [
            Expanded(
            child:Container(color:colors[(i+1)%4],height:100,),
            ),
            Expanded(
            child:Container(color:colors[(i+2)%4],height:100,),
            ),
            Expanded(
            child:Container(color:colors[(i+3)%4],height:100,),
            ),
            Expanded(
            child:Container(color:colors[(i)%4],height:100,),
            ),
          
            ]
             

          ),
         
         
              ElevatedButton(onPressed:(){
                i++;
                setState(() {
                  
                });

              }, child:Text('change'))

             
      ],
      ),
      
    );
  }
}