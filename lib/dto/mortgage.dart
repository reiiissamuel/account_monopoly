
class Mortgage{
   String id="";
   String name = "";
   int value = 0;
   int valueToPay = 0;
   int deadline = 3;
   int auctionMinValue = 0;
   bool alreadySetAuctionThisRound = false;

   Mortgage({required this.id, required this.name, required this.value, required this.valueToPay, required this.deadline,
      required this.auctionMinValue,
      required this.alreadySetAuctionThisRound});


   Mortgage.empty();

   Map<String, dynamic> toMap() {
      return {
         'id':  id,
         'name': name,
         'value': value,
         'valueToPay': valueToPay,
         'deadline':  deadline,
         'auctionMinValue': auctionMinValue,
         'alreadySetAuctionThisRound': alreadySetAuctionThisRound
      };
   }

   factory Mortgage.fromMap(Map<String, dynamic> map) {
      return Mortgage(
          id: map['id'] as String,
          name: map['name'] as String,
          value: map['value'] as int,
          valueToPay: map['valueToPay'] as int,
          deadline: map['deadline'] as int,
          auctionMinValue: map['auctionMinValue'] as int,
          alreadySetAuctionThisRound: map['alreadySetAuctionThisRound'] as bool
      );}
}