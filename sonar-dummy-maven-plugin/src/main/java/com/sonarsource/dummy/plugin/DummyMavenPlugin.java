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

public final class DummyMavenPlugin extends SonarPlugin {

  private static final Logger LOGGER = Logger.getLogger(DummyMavenPlugin.class.getName());

  @SuppressWarnings({ "rawtypes" })
  @Override
  public List getExtensions() {
    return Lists.newArrayList();
  }

  public static String sayHello() {
    String message = "Hello world!";
    LOGGER.info(message);
    return message;
  }

}
