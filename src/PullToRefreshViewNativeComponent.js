//  import type {
//   DirectEventHandler,
//   Float,
//   WithDefault,
// } from '../../Types/CodegenTypes';
// import type {ColorValue} from '../../StyleSheet/StyleSheet';
// import type {ViewProps} from '../View/ViewPropTypes';
import * as React from 'react';

import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
// import type {HostComponent} from '../../Renderer/shims/ReactNativeTypes';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';

// type NativeProps = $ReadOnly<{|
//   ...ViewProps,

//   /**
//    * The color of the refresh indicator.
//    */
//   tintColor?: ?ColorValue,
//   /**
//    * Title color.
//    */
//   titleColor?: ?ColorValue,
//   /**
//    * The title displayed under the refresh indicator.
//    */
//   title?: WithDefault<string, null>,
//   /**
//    * Progress view top offset
//    */
//   progressViewOffset?: WithDefault<Float, 0>,

//   /**
//    * Called when the view starts refreshing.
//    */
//   onRefresh?: ?DirectEventHandler<null>,

//   /**
//    * Whether the view should be indicating an active refresh.
//    */
//   refreshing: boolean,
// |}>;

export const Commands = codegenNativeCommands({
  supportedCommands: ['setNativeRefreshing'],
});

export default codegenNativeComponent('PullToRefreshView', {
  paperComponentName: 'RCTRefreshControlManagerCustom',
  excludedPlatforms: ['android'],
});
