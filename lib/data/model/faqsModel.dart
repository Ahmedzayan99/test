class FaqsModel {
  String? id;
  String? question;
  String? answer;
  String? status;
  bool? isExpanded;

  FaqsModel({this.id, this.question, this.answer, this.status, this.isExpanded});

  FaqsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
    status = json['status'];
    isExpanded = false;
  }

}