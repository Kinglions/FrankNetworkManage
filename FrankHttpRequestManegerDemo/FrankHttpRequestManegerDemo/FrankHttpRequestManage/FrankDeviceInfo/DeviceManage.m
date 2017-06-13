//
//  DeviceManage.m
//  YNYBZ
//
//  Created by Frank on 16/4/17.
//  Copyright © 2016年 Frank.HAJK. All rights reserved.
//

#import "DeviceManage.h"
#import <AFNetworking.h>

#import <sys/utsname.h>// get IP
#import <ifaddrs.h>
#import <arpa/inet.h>

#import <sys/sysctl.h>// get Mac
#import <net/if.h>
#import <net/if_dl.h>
#import <mach/machine.h>
#import <mach/mach_init.h>
#import <mach/host_info.h>
#import <math.h>
#import <sys/mount.h>
#import <mach/vm_map.h>
#import <mach/mach_host.h>



static DeviceManage * ynybz_DeviceManage = nil;

@interface DeviceManage ()<CLLocationManagerDelegate>

@property(nonatomic,strong)CLLocationManager * locationManage;


@end

@implementation DeviceManage


/**
 *  获取单例对象
 */
+(DeviceManage *)shareDeviceManage
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ynybz_DeviceManage = [[DeviceManage alloc]init];
    });
    return ynybz_DeviceManage;
}

-(instancetype)init
{
    if (self = [super init])
    {
        self.netWorkStatus = @"";
//        [self getLocation];
        [self currentNetWorkStatus];
        [self getDevicesMessage];
    }
    return self;
}


-(void)currentNetWorkStatus
{
    AFNetworkReachabilityManager * manage = [AFNetworkReachabilityManager sharedManager];

    [manage startMonitoring];
    
    [manage setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
       
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                
            case AFNetworkReachabilityStatusNotReachable:
                self.netWorkStatus = @"";// 未连接
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                self.netWorkStatus = @"wifi";// wifi
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                self.netWorkStatus = @"WWAN";// 手机网络
                break;
                
            default:
                break;
        }
        
    }];
}

/**
 *  获取网络状态
 */
-(void)getNetworkStatus
{
    AFNetworkReachabilityManager * manage = [AFNetworkReachabilityManager sharedManager];
    
    [manage setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
       
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                self.netWorkStatus = @"";// 未知网络
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                self.netWorkStatus = @"";// 未连接

                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                self.netWorkStatus = @"wifi";// wifi

                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                self.netWorkStatus = @"WWAN";// 手机网络

                break;
                
            default:
                break;
        }
        
    }];
    
    
}
/**
 *  获取设备信息
 */
-(void)getDevicesMessage
{
    self.screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    self.screenScale = [UIScreen mainScreen].scale;
    self.systemVersion = [[UIDevice currentDevice] systemVersion];
    self.systemName = [[UIDevice currentDevice] systemName];
    if ([self.systemName isEqualToString:@"iPhone OS"])
    {
        self.systemName = @"IOS";
    }
    self.deviceModel = [[UIDevice currentDevice] model];
    self.deviceName = [[UIDevice currentDevice] name];
    
    self.deviceType = [self deviceVersion];
    
    self.applicationDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    self.applicationIdentifier = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleIdentifier"];
    self.applicationMajorVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.applicationMinorVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.phoneIPAdress = [self getIPAddress];
    self.phoneMacAddress = [self getMacAddressFirst];
    
    self.cpuType = [self getCPUType];
    self.cpuCoreCount = [self cpuCount];
    self.totalMB = [self totalMemoryBytes];
    self.freeMB = [self freeMemoryBytes];
    self.totalDSB = [self totalDiskSpaceBytes];
    self.freeDSB = [self freeDiskSpaceBytes];
    
    
}

/**
 *  获取 IPMac
 */
- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    
    struct ifaddrs *interfaces = NULL;
    
    struct ifaddrs *temp_addr = NULL;
    
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        
        // Loop through linked list of interfaces
        
        temp_addr = interfaces;
        
        while(temp_addr != NULL) {
            
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                
                // Check if interface is en0 which is the wifi connection on the iPhone
                
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    
                    // Get NSString from C String
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
        
    }
    
    // Free memory
    
    freeifaddrs(interfaces);
    
    return address;
}
/**
 *  获取Mac地址 方法 1 ：
 */
- (NSString *) getMacAddressFirst
{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    
    free(buf);
    
    return [outstring uppercaseString];
}
/**
 *  获取Mac地址 方法 2 ：
 */
- (NSString *)getMacAddressSecond
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

/**
 *  获取设备型号
 */
-(NSString*)deviceVersion
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    //iPod
    
    if ([deviceString isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    
    //iPad
    if ([deviceString isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"i386"])         return @"iPhone Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"iPhone Simulator";
    
    if ([deviceString isEqualToString:@"iPad4,4"]||[deviceString isEqualToString:@"iPad4,5"]||[deviceString isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    
    if ([deviceString isEqualToString:@"iPad4,7"]||[deviceString isEqualToString:@"iPad4,8"]||[deviceString isEqualToString:@"iPad4,9"])  return @"iPad mini 3";
    
    return deviceString;
}



//#pragma mark sysctl utils
- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

/**
 *  cpu类型
 */
- (NSString *)getCPUType{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    
    /*Declaration of 'host_info' must be imported from module 'Darwin.Mach.mach_host' before it is required
     
     #define CPU_TYPE_MC98000	((cpu_type_t) 10)
     #define CPU_TYPE_HPPA           ((cpu_type_t) 11)
     #define CPU_TYPE_ARM		((cpu_type_t) 12)
     #define CPU_TYPE_ARM64          (CPU_TYPE_ARM | CPU_ARCH_ABI64)
     #define CPU_TYPE_MC88000	((cpu_type_t) 13)
     #define CPU_TYPE_SPARC		((cpu_type_t) 14)
     #define CPU_TYPE_I860		((cpu_type_t) 15)
     
     */
    
    NSString * cpuType = @"";
    
    switch (hostInfo.cpu_type) {
        case CPU_TYPE_ARM:
            NSLog(@"CPU_TYPE_ARM");
            cpuType = @"ARM";
            
            break;
            
        case CPU_TYPE_ARM64:
            NSLog(@"CPU_TYPE_ARM64");
            cpuType = @"ARM64";

            break;
            
        case CPU_TYPE_X86:
            NSLog(@"CPU_TYPE_X86");
            cpuType = @"X86";

            break;
            
        case CPU_TYPE_X86_64:
            NSLog(@"CPU_TYPE_X86_64");
            cpuType = @"X86_64";
            break;
            
        default:
            break;
    }
    
    return cpuType;
}
/**
 *  cpu 内核个数
 */
- (NSUInteger) cpuCount
{
    return [self getSysInfo:HW_NCPU];
}
/**
 *  cup 频率
 */
- (NSUInteger)cpuFrequency {
    return [self getSysInfo:HW_CPU_FREQ];
}
/**
 *  cpu 使用情况
 */
- (NSArray *)cpuUsage
{
    NSMutableArray *usage = [NSMutableArray array];
    //    float usage = 0;
    processor_info_array_t _cpuInfo, _prevCPUInfo = nil;
    mach_msg_type_number_t _numCPUInfo, _numPrevCPUInfo = 0;
    unsigned _numCPUs;
    NSLock *_cpuUsageLock;
    
    int _mib[2U] = { CTL_HW, HW_NCPU };
    size_t _sizeOfNumCPUs = sizeof(_numCPUs);
    int _status = sysctl(_mib, 2U, &_numCPUs, &_sizeOfNumCPUs, NULL, 0U);
    if(_status)
        _numCPUs = 1;
    
    _cpuUsageLock = [[NSLock alloc] init];
    
    natural_t _numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &_numCPUsU, &_cpuInfo, &_numCPUInfo);
    if(err == KERN_SUCCESS) {
        [_cpuUsageLock lock];
        
        for(unsigned i = 0U; i < _numCPUs; ++i) {
            Float32 _inUse, _total;
            if(_prevCPUInfo) {
                _inUse = (
                          (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                          );
                _total = _inUse + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                _inUse = _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                _total = _inUse + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            
            //            YnybzLog(@"Core : %u, Usage: %.2f%%", i, _inUse / _total * 100.f);
            float u = _inUse / _total * 100.f;
            [usage addObject:[NSNumber numberWithFloat:u]];
        }
        
        [_cpuUsageLock unlock];
        
        if(_prevCPUInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * _numPrevCPUInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)_prevCPUInfo, prevCpuInfoSize);
        }
        
        _prevCPUInfo = _cpuInfo;
        _numPrevCPUInfo = _numCPUInfo;
        
        _cpuInfo = nil;
        _numCPUInfo = 0U;
    } else {
        NSLog(@"Error!");
    }
    return usage;
}

#pragma mark memory information
/**
 *  手机内存容量
 */
- (NSString *) totalMemoryBytes
{
    return [self changeToGBSizeWithBytes:[self getSysInfo:HW_PHYSMEM]];
}
/**
 *  剩余手机内存容量
 */
- (NSString *) freeMemoryBytes
{
    mach_port_t           host_port = mach_host_self();
    mach_msg_type_number_t   host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t               pagesize;
    vm_statistics_data_t     vm_stat;
    
    host_page_size(host_port, &pagesize);
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) NSLog(@"Failed to fetch vm statistics");
    
    //    natural_t   mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
    natural_t   mem_free = vm_stat.free_count * pagesize;
    //    natural_t   mem_total = mem_used + mem_free;
    
    return [self changeToGBSizeWithBytes:mem_free];
}

#pragma mark disk information
/**
 *  手机空闲存储容量
 */
- (NSString *) freeDiskSpaceBytes
{
    struct statfs buf;
    long long freespace;
    freespace = 0;
    if(statfs("/private/var", &buf) >= 0){
        freespace = (long long)buf.f_bsize * buf.f_bfree;
    }
    return [self changeToGBSizeWithBytes:freespace];
}
/**
 *  手机总存储容量
 */
- (NSString *) totalDiskSpaceBytes
{
    struct statfs buf;
    long long totalspace;
    totalspace = 0;
    if(statfs("/private/var", &buf) >= 0){
        totalspace = (long long)buf.f_bsize * buf.f_blocks;
    }
    return [self changeToGBSizeWithBytes:totalspace];
}
-(NSString *)changeToGBSizeWithBytes:(long long)byte{
    
    float size = (float)byte;
    
    NSInteger i = 1;
    while (size) {
        size = size/1024;
        i++;
        if (i >= 4) break;
    }
    return [NSString stringWithFormat:@"%.2f G",size];
}




@end
