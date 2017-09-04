//
//  JSWebView.h
//  JSWebView
//
//  Created by songguanchen on 2017/9/4.
//  Copyright © 2017年 songguanchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

typedef void(^CallBack)();
typedef void(^CallBackWithOneParameter)(id object);

typedef NS_ENUM(NSInteger, JSPaneType)
{
    JSPaneTypeAlert,
    JSPaneTypeConfirm,
    JSPaneTypeInputText
};

@protocol JSWebViewValueChangeDelegate <NSObject>

@optional
- (void)valueDidChange:(NSDictionary *)change;

@end

@interface JSWebView : UIView

@property (nonatomic, weak)id<JSWebViewValueChangeDelegate> delegate;

/**
 配置参数同时加载H5页面

 @param urlString H5文件名
 */
- (void) setupConfigAndLoadUrlStr_H5:(NSString *)urlString;

/**
 注入JS对象名称，并执行方法

 @param name JS
 @param callBack 参数为JS传回的信息
 */
- (void) addScriptMessageHandle:(NSString *)name AndExecute:(CallBackWithOneParameter)callBack;

/**
 执行JS函数

 @param javaScriptString JS命令
 @param callBack 执行后调用
 */
- (void) evaluateJavaScript:(NSString *)javaScriptString EndCallBack:(CallBack)callBack;

/**
 替换原生JS弹框

 @param title 标题
 @param message 提示信息
 @param paneType 弹窗类型
 */
- (void) showPaneWithTitle:(NSString *)title Message:(NSString *)message Type:(JSPaneType)paneType;

/**
 */
- (void) goBack;

- (void) goForward;
/*
 重写config的Setter和Getter方法
 */
- (void) setConfig:(WKWebViewConfiguration *)config;
- (WKWebViewConfiguration *)config;

@end
