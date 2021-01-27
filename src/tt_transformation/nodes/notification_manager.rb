require 'set'

module TT::Plugins::TransformationInspector
  class NotificationManager

    def self.default
      @default ||= self.new
      @default
    end

    def initialize
      @listeners = Set.new
    end

    def add_listener(listener)
      @listeners.add(listener)
      nil
    end

    def remove_listener(listener)
      @listeners.delete(listener)
      nil
    end

    def reset
      @listeners.clear
    end

    # @param [Symbol] event_id
    # @param [Hash] data
    def notify(event_id, data)
      callback = "on_#{event_id}".to_sym
      # puts "notify: #{callback.inspect} (#{@listeners.size} listeners)"
      @listeners.each { |listener|
        # p [listener, listener.respond_to?(callback)]
        next unless listener.respond_to?(callback)

        begin
          listener.send(callback, data)
        rescue => error
          puts "Error while triggering event: #{error.class.name}"
          puts error.message
          puts error.backtrace.join("\n")
        end
      }
    end

  end # class NotificationManager
end
