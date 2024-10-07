class ChatModel {
  String? id;
  String? userType;
  String? userId;
  String? ticketId;
  String? message;
  String? name;
  List<Attachments>? attachments;
  String? subject;
  String? lastUpdated;
  String? dateCreated;

  ChatModel(
      {this.id,
        this.userType,
        this.userId,
        this.ticketId,
        this.message,
        this.name,
        this.attachments,
        this.subject,
        this.lastUpdated,
        this.dateCreated});

  ChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userType = json['user_type'];
    userId = json['user_id'];
    ticketId = json['ticket_id'];
    message = json['message'];
    name = json['name'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
    subject = json['subject'];
    lastUpdated = json['last_updated'];
    dateCreated = json['date_created'];
  }
}

class Attachments {
  String? media;
  String? type;

  Attachments({this.media, this.type});

  Attachments.fromJson(Map<String, dynamic> json) {
    media = json['media'];
    type = json['type'];
  }

}