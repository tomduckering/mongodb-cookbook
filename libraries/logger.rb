module LogHelper

  def LogHelper.running_under_chef
    (defined?(Chef) == 'constant')
  end

  def LogHelper.log(level, message)
    puts ("#{level}: #{message}")
  end

  def LogHelper.info(message)
    log("info", message) unless running_under_chef
    Chef::Log.info(message) if running_under_chef
  end

  def LogHelper.warn(message)
    log("warn", message) unless running_under_chef
    Chef::Log.warn(message) if running_under_chef
  end

  def LogHelper.error(message)
    log("error", message) unless running_under_chef
    Chef::Log.error(message) if running_under_chef
  end

  def LogHelper.fatal(message)
    log("fatal", message) unless running_under_chef
    Chef::Log.fatal(message) if running_under_chef
  end
end