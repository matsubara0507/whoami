module Whoami.Service.Internal.Uniform where

import           RIO

import           Whoami.Service.Data.Class (ServiceException (..), ServiceM)

throwUniformError :: Text -> ServiceM a
throwUniformError = throwM . UniformException
