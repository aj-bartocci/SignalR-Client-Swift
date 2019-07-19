//
//  HubConnectionBuilder.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 7/8/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class HubConnectionBuilder {
    private let url: URL
    private var hubProtocolFactory: (Logger) -> HubProtocol = {logger in JSONHubProtocol(logger: logger)}
    private let httpConnectionOptions = HttpConnectionOptions()
    private var logger: Logger = NullLogger()
    private var delegate: HubConnectionDelegate?

    public init(url: URL) {
        self.url = url
    }

    public func withHubProtocol(hubProtocolFactory: @escaping (Logger) -> HubProtocol) -> HubConnectionBuilder {
        self.hubProtocolFactory = hubProtocolFactory
        return self
    }

    public func withHttpConnectionOptions(configureHttpOptions: (_ httpConnectionOptions: HttpConnectionOptions) -> Void) -> HubConnectionBuilder {
        configureHttpOptions(httpConnectionOptions)
        return self
    }

    public func withLogging(minLogLevel: LogLevel) -> HubConnectionBuilder {
        logger = FilteringLogger(minLogLevel: minLogLevel, logger: PrintLogger())
        return self
    }

    public func withLogging(logger: Logger) -> HubConnectionBuilder {
        self.logger = logger
        return self
    }

    public func withLogging(minLogLevel: LogLevel, logger: Logger) -> HubConnectionBuilder {
        self.logger = FilteringLogger(minLogLevel: minLogLevel, logger: logger)
        return self
    }

    public func withHubConnectionDelegate(delegate: HubConnectionDelegate) -> HubConnectionBuilder {
        self.delegate = delegate
        return self
    }

    public func build() -> HubConnection {
        let httpConnection = HttpConnection(url: url, options: httpConnectionOptions, logger: logger)
        let hubConnection = HubConnection(connection: httpConnection, hubProtocol: hubProtocolFactory(logger), logger: logger)
        hubConnection.delegate = delegate
        return hubConnection
    }
}

public extension HubConnectionBuilder {
    func withJSONHubProtocol() -> HubConnectionBuilder {
        return self.withHubProtocol(hubProtocolFactory: {logger in JSONHubProtocol(logger: logger)})
    }
}
