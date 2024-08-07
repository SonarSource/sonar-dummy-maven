/*
 * Copyright (C) 2014-2024 SonarSource SA
 * All rights reserved
 * mailto:info AT sonarsource DOT com
 */
package com.sonarsource.dummy.plugin;


import org.junit.Before;
import org.junit.Test;

import static org.fest.assertions.Assertions.assertThat;


public class DummyMavenPluginTest {

  private DummyMavenPlugin dummyMavenPlugin;

  @Before
  public void setUp(){
    dummyMavenPlugin = new DummyMavenPlugin();
  }

  @Test
  public void getExtensionsShouldReturnAnEmptyListWhenPluginInstantiated() {

    assertThat(dummyMavenPlugin.getExtensions()).isEmpty();
  }

  @Test
  public void sayHelloShouldReturnHelloWorldMessage() {

    assertThat(DummyMavenPlugin.sayHello()).isEqualTo("Hello world!");
  }
}
