global class MyEmailService implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope
    ) {
        // 1. 解析邮件
        String subject = email.subject;
        String body = email.plainTextBody;

        // 2. 业务处理（示例：创建Case）
        Case c = new Case(
            Subject = subject,
            Description = body,
            SuppliedEmail = envelope.fromAddress
        );
        insert c;

        // 3. 返回处理结果
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true;
        return result;
    }
}