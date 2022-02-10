/*
 * Copyright (C) 2014-2022 SonarSource SA
 * All rights reserved
 * mailto:info AT sonarsource DOT com
 */
package com.sonarsource.dummy.plugin;

import java.util.List;
import org.sonar.api.SonarPlugin;
import com.google.common.collect.Lists;

public final class DummyPlugin extends SonarPlugin {

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Override
  public List getExtensions() {
    return Lists.newArrayList();
  }

  
  public String sayHello() {
    System.out.println("hello");
    System.out.println("world");
    return "hello";
  }

}
