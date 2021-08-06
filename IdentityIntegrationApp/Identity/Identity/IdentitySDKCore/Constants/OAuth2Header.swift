//
//  OAuth2.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 05/07/21.
//

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
