
/* Copyright (c) 2021 CyberArk Software Ltd. All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

enum OAuth2Header: String {
    case code = "code"
    case clientId = "client_id"
    case scope = "scope"
    case redirecUri = "redirect_uri"
    case decision = "decision"
    case responseType = "response_type"
    case codeVerifier = "code_verifier"
    case codeChallenge = "code_challenge"
    case codeChallengeMethod = "code_challenge_method"
    case grantType = "grant_type"
    case grantTypeAuthCode = "authorization_code"
    case token = "token"
    case csrf = "csrf"
    case authorization = "Authorization"
    case state = "state"
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case idToken = "id_token"
    case tokenType = "token_type"
    case tokenExpiresIn = "expires_in"
    case postLogoutRedirectUri = "post_logout_redirect_uri"
}
