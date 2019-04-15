/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.alipay.sofa.jraft.rhea.server;

import java.io.Closeable;
import java.io.File;
import java.io.IOException;

import com.alipay.sofa.jraft.rhea.client.DefaultRheaKVStore;
import com.alipay.sofa.jraft.rhea.client.RheaKVStore;
import com.alipay.sofa.jraft.rhea.options.RheaKVStoreOptions;
import com.alipay.sofa.jraft.util.Requires;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;

/**
 * just a copy from example
 *
 * @author shuwei.gsw
 */
public class RheaKvServerBootstrap implements Closeable {

    private ServerNode node;

    public void initStoreOptionsFromYaml(String file) throws IOException {
        ObjectMapper mapper = new ObjectMapper(new YAMLFactory());
        RheaKVStoreOptions opts = mapper.readValue(new File(file), RheaKVStoreOptions.class);
        this.node = new ServerNode(opts);
    }

    public void start() {
        Requires.requireNonNull(node, "node must init before start");
        node.start();
    }

    @Override
    public void close() {
        if (node != null) {
            node.stop();
        }
    }

    public static void main(final String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: " + RheaKvServerBootstrap.class.getName() + " rheakv.yaml");
            System.exit(1);
        }

        RheaKvServerBootstrap bootstrap = new RheaKvServerBootstrap();
        bootstrap.initStoreOptionsFromYaml(args[0]);

        System.out.println("RheaKv server starting...");
        bootstrap.start();

        Runtime.getRuntime().addShutdownHook(new Thread(bootstrap::close));
        System.out.println("RheaKv server start OK");
    }

    public static class ServerNode {
        private final RheaKVStoreOptions options;

        private RheaKVStore              rheaKVStore;

        public ServerNode(RheaKVStoreOptions options) {
            this.options = options;
        }

        public void start() {
            this.rheaKVStore = new DefaultRheaKVStore();
            this.rheaKVStore.init(this.options);
        }

        public void stop() {
            this.rheaKVStore.shutdown();
        }

        public RheaKVStore getRheaKVStore() {
            return rheaKVStore;
        }
    }

}
