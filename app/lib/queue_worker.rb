require 'bunny'

module QueueWorker
  def self.run
    connection = Bunny.new(hostname: "rabbitmq:5672", automatically_recover: true)
    connection.start

    channel = connection.create_channel
    queue = channel.queue('jobs')

    channel.prefetch(1)

    begin
      queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
        parsed_message_body = JSON.parse(body)

        if parsed_message_body.key? "message"
          parent_application = ClientApplication.find_by_identifier_token(parsed_message_body["message"]["application_token"])
          self.handle_message(parent_application, parsed_message_body)
        else
          parent_application = ClientApplication.find_by_identifier_token(parsed_message_body["chat"]["application_token"])
          self.handle_chat(parent_application, parsed_message_body)
        end
        channel.ack(delivery_info.delivery_tag)
      end
    rescue Interrupt => _
      connection.close
    end
  end

  def self.update_message(parent_chat, parsed_message_body)
    message = parent_chat.messages.find_by(identifier_number: parsed_message_body["message"]["number"])
    message.update(text: parsed_message_body["message"]["text"])
  end

  def self.create_message(parent_chat, parsed_message_body)
    parent_chat.messages.create(
        text: parsed_message_body["message"]["text"],
        identifier_number: parsed_message_body["message"]["number"]
    )
  end

  def self.handle_message(parent_application, parsed_message_body)
    parent_chat = parent_application.chats.find_by(identifier_number: parsed_message_body["message"]["chat_number"])
    if parsed_message_body["type"] == "edit"
      self.update_message(parent_chat, parsed_message_body)
    else
      self.create_message(parent_chat, parsed_message_body)
    end
  end

  def self.update_chat(parent_application, parsed_message_body)
    chat = parent_application.chats.find_by(identifier_number: parsed_message_body["chat"]["number"])
    chat.update(modifiable_attribute: parsed_message_body["message"]["modifiable_attribute"])
  end

  def self.create_chat(parent_application, parsed_message_body)
    parent_application.chats.create(identifier_number: parsed_message_body["chat"]["number"])
  end

  def self.handle_chat(parent_application, parsed_message_body)
    if parsed_message_body["type"] == "edit"
      self.update_chat(parent_application, parsed_message_body)
    else
      self.create_chat(parent_application, parsed_message_body)
    end
  end
end

QueueWorker.run