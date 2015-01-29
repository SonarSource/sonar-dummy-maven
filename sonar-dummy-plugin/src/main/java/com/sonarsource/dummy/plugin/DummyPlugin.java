/*
 * Copyright (C) 2014-2014 SonarSource SA
 * All rights reserved
 * mailto:contact AT sonarsource DOT com
 */
package com.sonarsource.dummy.plugin;

import java.util.List;
import com.google.common.collect.Lists;
import com.sonarsource.license.api.LicensedPlugin;
import com.sonarsource.license.api.LicensedPluginMetadata;

public final class DummyPlugin extends LicensedPlugin {

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Override
  private List doGetExtensions() {
    return Lists.newArrayList();
  }

  @Override
  private LicensedPluginMetadata doGetPluginMetadata() {
    return null;
  }

}
