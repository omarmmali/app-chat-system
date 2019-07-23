require 'bunny'
require 'sneakers'

class QueueWorker
  include Sneakers::Worker
  from_queue 'jobs'

  def work(queued_job)
    parsed_message_body = JSON.parse(queued_job)

    if parsed_message_body.key? "message"
      parent_application = ClientApplication.find_by_identifier_token(parsed_message_body["message"]["application_token"])
      handle_message(parent_application, parsed_message_body)
    elsif parsed_message_body.key? "chat"
      parent_application = ClientApplication.find_by_identifier_token(parsed_message_body["chat"]["application_token"])
      handle_chat(parent_application, parsed_message_body)
    else
      handle_application(parsed_message_body)
    end
    ack!
  end


  def handle_application(parsed_message_body)
    if parsed_message_body["type"] == "edit"
      edit_application(parsed_message_body["application"]["token"], parsed_message_body["application"]["name"])
    else
      create_application(parsed_message_body["application"]["token"], parsed_message_body["application"]["name"])
    end
  end

  def edit_application(token, name)
    ClientApplication.find_by_identifier_token(token).update(name: name)
  end

  def create_application(token, name)
    ClientApplication.create(identifier_token: token, name: name)
  end

  def update_message(parent_chat, parsed_message_body)
    message = parent_chat.messages.find_by(identifier_number: parsed_message_body["message"]["number"])
    message.update(text: parsed_message_body["message"]["text"])
  end

  def create_message(parent_chat, parsed_message_body)
    parent_chat.messages.create(
        text: parsed_message_body["message"]["text"],
        identifier_number: parsed_message_body["message"]["number"]
    )
    increment_parent_chat_message_count(parent_chat)
  end

  def handle_message(parent_application, parsed_message_body)
    parent_chat = parent_application.chats.find_by(identifier_number: parsed_message_body["message"]["chat_number"])
    if parsed_message_body["type"] == "edit"
      update_message(parent_chat, parsed_message_body)
    else
      create_message(parent_chat, parsed_message_body)
    end
  end

  def update_chat(parent_application, parsed_message_body)
    chat = parent_application.chats.find_by(identifier_number: parsed_message_body["chat"]["number"])
    chat.update(modifiable_attribute: parsed_message_body["message"]["modifiable_attribute"])
  end

  def create_chat(parent_application, parsed_message_body)
    parent_application.chats.create(identifier_number: parsed_message_body["chat"]["number"])

    increment_parent_application_chat_count(parent_application)
  end

  def handle_chat(parent_application, parsed_message_body)
    if parsed_message_body["type"] == "edit"
      update_chat(parent_application, parsed_message_body)
    else
      create_chat(parent_application, parsed_message_body)
    end
  end

  private

  def increment_parent_application_chat_count(parent_application)
    parent_application.chat_count += 1
    parent_application.save
  end

  def increment_parent_chat_message_count(parent_chat)
    parent_chat.message_count += 1
    parent_chat.save
  end
end