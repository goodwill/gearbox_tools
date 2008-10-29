# Include hook code here

ActionController::Base.helper(ErrorMessageHelper)

# by default we include authenticated system for all application controller, remark this to override
ActionController::Base.send(:include, AuthenticatedSystem)