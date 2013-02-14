require 'action_mailer'

module Delayed
  class PerformableMailer < PerformableMethod
    def perform
      load(object).send(method, *args.map{|a| load(a)}).deliver
    rescue PerformableMethod::LoadError
      # We cannot do anything about objects that can't be loaded
      true
    end
  end
end

ActionMailer::Base.class_eval do
  def self.delay(options = {})
    Delayed::DelayProxy.new(Delayed::PerformableMailer, self, options)
  end
end

Mail::Message.class_eval do
  def delay(*args)
    raise RuntimeError, "Use MyMailer.delay.mailer_action(args) to delay sending of emails."
  end
end
