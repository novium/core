defmodule CoreWeb.Guardian.BrowserAuthPipeline do
    use Guardian.Plug.Pipeline, otp_app: :core,
        module: CoreWeb.Guardian,
        error_handler: CoreWeb.UserManager.ErrorHandler
    
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource, allow_blank: true
end