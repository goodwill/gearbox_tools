# by default we include authenticated system for all application controller, remark this to override
ActionController::Base.send(:include, AuthenticatedSystem)