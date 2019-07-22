module WorkQueue
  def self.enqueue_job(chat_message)
    connection = Bunny.new(hostname: 'rabbitmq:5672').start
    work_queue = connection.create_channel.queue('jobs')
    work_queue.publish(chat_message.to_json.to_s)
    connection.close
  end
end
