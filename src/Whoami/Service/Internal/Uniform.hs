module Whoami.Service.Internal.Uniform where

import           Control.Monad.Error.Class (throwError)
import           Data.Text                 (Text)
import           Whoami.Service.Data.Class (ServiceM, UniformException (..))

throwUniformError :: Text -> ServiceM a
throwUniformError = throwError . UniformException
