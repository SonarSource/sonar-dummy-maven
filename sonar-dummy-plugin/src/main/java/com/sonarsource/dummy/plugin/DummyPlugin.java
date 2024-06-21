/*
 * Copyright (C) 2014-2024 SonarSource SA
 * All rights reserved
 * mailto:info AT sonarsource DOT com
 */
package com.sonarsource.dummy.plugin;

import java.util.List;
import java.util.logging.Logger;
import org.sonar.api.SonarPlugin;
import com.google.common.collect.Lists;

public final class DummyPlugin extends SonarPlugin {

  iprivate static final Logger LOGGER = Logger.getLogger(DummyPlugin.class.getName());

  @SuppressWarnings({ "rawtypes" })
  @Override
  public List getExtensions() {
    return Lists.newArrayList();
  }

  public static String sayHello() {
    String message = "hello world";
    LOGGER.info(message);
    return message;
  }

}
