//
//  JSWebView.m
//  JSWebView
//
//  Created by songguanchen on 2017/9/4.
//  Copyright © 2017年 songguanchen. All rights reserved.
//

#import "JSWebView.h"

@interface JSWebView()<WKUIDelegate,WKScriptMessageHandler>
{
    WKWebViewConfiguration *_config;
}
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong)UIProgressView *progressView;

@property (nonatomic) id<WKUIDelegate> UIDelegate;
@property (nonatomic) id<WKNavigationDelegate> NavDelegate;

@property (nonatomic, strong) NSMutableDictionary *callBackDictionary;
@property (nonatomic, strong) NSMutableDictionary *infoDictionary;
@property (nonatomic, strong) NSMutableDictionary *changeDictionary;
@end
@implementation JSWebView

#pragma --mark 初始化
- (void) loadUrlStr_H5:(NSString *)urlString
{
    NSArray *pathsArray = [urlString componentsSeparatedByString:@"."];
    NSURL *path = [[NSBundle mainBundle]URLForResource:pathsArray[0] withExtension:pathsArray[1]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:path]];
}

- (void) setupConfigAndLoadUrlStr_H5:(NSString *)urlString
{
    self.webView = [[WKWebView alloc]initWithFrame:self.bounds configuration:_config];
    
    self.webView.UIDelegate         = _UIDelegate;
    self.webView.navigationDelegate = _NavDelegate;
    
    [self loadUrlStr_H5:urlString];
    [self addSubview:_webView];
    
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (instancetype) initWithFrame:(CGRect)frame
                  UIDelegate:(id<WKUIDelegate>)UIDelegate
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _config = [[WKWebViewConfiguration alloc]init];
        _config.userContentController = [[WKUserContentController alloc]init];
        _config.preferences = [[WKPreferences alloc]init];
        
        self.UIDelegate  = UIDelegate;
    
        self.callBackDictionary = [NSMutableDictionary dictionary];
        self.infoDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma --mark KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [self.changeDictionary setObject:change forKey:keyPath];
    if (_delegate && [self respondsToSelector:@selector(valueDidChange:)]) {
        [_delegate valueDidChange:self.changeDictionary];
    }
}

#pragma --mark MessageHandler
- (void) userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
     if ([self.callBackDictionary.allKeys containsObject:message.name] ) {
         CallBack callBackAction = [self.callBackDictionary objectForKey:message.name];
         if (callBackAction && callBackAction !=nil) {
             callBackAction(message.body);
         }
    }
}

- (void) addScriptMessageHandle:(NSString *)name AndExecute:(CallBackWithOneParameter)callBack
{
    id callBackAction = [self.callBackDictionary objectForKey:name];
    if (callBackAction !=nil && ![callBackAction isKindOfClass:[NSNull class]]) {
        [self.callBackDictionary removeObjectForKey:name];
        _Block_release((__bridge const void *)(callBackAction));
    }
    
    void const *callBackBlock = Block_copy((__bridge const void *)callBack);
    [self.callBackDictionary setObject:(__bridge id _Nonnull)(callBackBlock) forKey:name];
}

#pragma --mark 执行JS函数
- (void) evaluateJavaScript:(NSString *)javaScriptString EndCallBack:(CallBack)callBack
{
    [self.webView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"%s",__FUNCTION__);
        NSLog(@"response:%@,error:%@",response,error);
        if (callBack != nil && callBack ) {
            callBack();
        }
    }];
}

#pragma --mark 替换原生弹窗
- (void) transformDictionaryWithTitle:(NSString *)title Message:(NSString *)message Type:(JSPaneType)paneType
{
    NSMutableString *mergeString = [NSMutableString string];
    [mergeString appendString:title];
    [mergeString appendString:@"{***}"];
    [mergeString appendString:message];
    [self.infoDictionary setObject:mergeString forKey:[NSNumber numberWithInteger:paneType]];
}

- (NSArray *)arrayWithMergeString:(NSString *)mergeString
{
    NSArray *infoArray = [mergeString componentsSeparatedByString:@"{***}"];
    return infoArray;
}

- (void) showPaneWithTitle:(NSString *)title Message:(NSString *)message Type:(JSPaneType)paneType
{
    [self transformDictionaryWithTitle:title Message:message Type:paneType];
}

- (void) webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSString *mergeString = [self.infoDictionary objectForKey:[NSNumber numberWithInteger:JSPaneTypeAlert]];
    NSArray *infoArray = [self arrayWithMergeString:mergeString];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:infoArray[0] message:infoArray[1] preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
}

- (void) webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    NSString *mergeString = [self.infoDictionary objectForKey:[NSNumber numberWithInteger:JSPaneTypeConfirm]];
    NSArray *infoArray = [self arrayWithMergeString:mergeString];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:infoArray[0] message:infoArray[1] preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
}

- (void) webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    NSString *mergeString = [self.infoDictionary objectForKey:[NSNumber numberWithInteger:JSPaneTypeInputText]];
    NSArray *infoArray = [self arrayWithMergeString:mergeString];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:infoArray[0] message:infoArray[1] preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    //TODO modifiy textField
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alertController.textFields lastObject] text]);
    }]];
}
#pragma --mark SetterAndGetter Method
- (void) setConfig:(WKWebViewConfiguration *)config{
   _config  = config;
}

- (WKWebViewConfiguration *)config{
    return _config;
}

- (void) goBack
{
//TODO
}
- (void) goForward
{
//TODO
}

@end
