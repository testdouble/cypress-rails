class ExternalService
  class << self
    def start_service
      @job_pid = fork {
        exec "yarn start"
      }
      Process.detach(@job_pid)
    end

    def stop_service
      all_processes.each do |pid|
        Process.kill("SIGINT", pid.to_i)
      end
    end

    def all_processes
      get_child_processes << @job_pid
    end

    def get_child_processes
      pipe = IO.popen("ps -ef | grep #{@job_pid}")

      child_pids = pipe.readlines.map { |line|
        parts = line.split(/\s+/)
        parts[1] if parts[2] == @job_pid.to_s && parts[1] != pipe.pid.to_s
      }.compact

      pipe.close
      # Reverse the child processes to keep the correct tree spawn structure
      child_pids.reverse
    end
  end
end
