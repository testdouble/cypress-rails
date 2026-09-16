class ExternalService
  class << self
    def start_service
      @pid = Process.spawn("yarn start", pgroup: true)
    end

    def stop_service
      return unless @pid
      Process.kill("-TERM", @pid)
      Process.wait(@pid)
    rescue Errno::ESRCH, Errno::ECHILD
      # already exited
    ensure
      @pid = nil
    end
  end
end
