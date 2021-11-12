class Petition {

  String startdate = "", enddate = "", goal = "", initiator = "",
      addressee = "", description = "", signer = "", title = "";

  Petition(
      {required this.startdate,
        required this.enddate,
        required this.goal,
        required this.initiator,
        required this.addressee,
        required this.description,
        required this.signer,
        required this.title});

  Petition.fromJson(Map<String, dynamic> json) {
    addressee = json['addressee'.toString()];
    description = json['description'.toString()];
    enddate = json['enddate'.toString()];
    goal = json['goal'.toString()];
    initiator = json['initiator'.toString()];
    signer = json['signer'.toString()];
    startdate = json['startdate'.toString()];
    title = json['title'.toString()];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startdate'] = this.startdate;
    data['enddate'] = this.enddate;
    data['goal'] = this.goal;
    data['initiator'] = this.initiator;
    data['addressee'] = this.addressee;
    data['description'] = this.description;
    data['signer'] = this.signer;
    data['title'] = this.title;
    return data;
  }

  factory Petition.fromJsonToObject(dynamic json) {


    return Petition(
      addressee : json.containsKey("addressee") ? json["addressee"].toString() : "--",
      description : json.containsKey("description") ? json["description"].toString() : "--",
      enddate : json.containsKey("enddate") ? json["enddate"].toString() : "--",
      goal : json.containsKey("goal") ? json["goal"].toString() : "--",
      initiator : json.containsKey("initiator") ? json["initiator"].toString() : "--",
      signer : json.containsKey("signer") ? json["signer"].toString() : "--",
      startdate : json.containsKey("startdate") ? json["startdate"].toString() : "--",
      title : json.containsKey("title") ? json["title"].toString() : "--"
    );
  }

  @override
  String toString(){
    return '{ title: ${this.title}, startdate: ${this.startdate}, enddate: ${this.enddate}, signer: ${this.signer} goal: ${this.goal},'
        'initiator: ${this.initiator}, adressee: ${this.addressee}, description: ${this.description}  }';
  }
}
