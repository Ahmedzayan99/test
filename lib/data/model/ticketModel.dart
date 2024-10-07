class TicketModel {
  String? id;
  String? ticketTypeId;
  String? userId;
  String? subject;
  String? email;
  String? description;
  String? status;
  String? lastUpdated;
  String? dateCreated;
  String? name;
  String? ticketType;

  TicketModel(
      {this.id,
        this.ticketTypeId,
        this.userId,
        this.subject,
        this.email,
        this.description,
        this.status,
        this.lastUpdated,
        this.dateCreated,
        this.name,
        this.ticketType});

  TicketModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ticketTypeId = json['ticket_type_id'];
    userId = json['user_id'];
    subject = json['subject'];
    email = json['email'];
    description = json['description'];
    status = json['status'];
    lastUpdated = json['last_updated'];
    dateCreated = json['date_created'];
    name = json['name'];
    ticketType = json['ticket_type'];
  }

}