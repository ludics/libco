Libco
===========

> **目录结构（本仓库重构版）**
>
> ```
> libco/
> ├── src/          # 协程库源码与头文件（co_routine、coctx、co_epoll、hook 等）
> ├── example/      # 使用示例（example_echosvr、example_thread 等）
> ├── bench/        # 基准测试（bench_swap：协程切换开销实测）
> ├── Makefile      # make 构建（产物全部输出到 build/，make / make lib / make clean）
> ├── CMakeLists.txt# cmake 构建（cmake -B build-cmake）
> └── build/        # 构建产物（gitignore）：obj/ 目标文件、lib/ 库、bin/ 可执行文件
> ```
>
> 构建与测试：
> ```bash
> make -j8                                  # 构建全部
> ./build/bin/bench_swap                    # 协程切换基准
> ./build/bin/example_echosvr 127.0.0.1 28960 1 1 &
> ./build/bin/example_echocli 127.0.0.1 28960 1 1
> ```
>
> 本仓库在原版基础上补充了 aarch64/arm64 支持（macOS Apple Silicon 与 Linux aarch64 均可原生编译运行），x86 路径保持原版不变。

Libco is a c/c++ coroutine library that is widely used in WeChat services. It has been running on tens of thousands of machines since 2013.

By linking with libco, you can easily transform synchronous back-end service into coroutine service. The coroutine service will provide out-standing concurrency compare to multi-thread approach. With the system hook, You can easily coding in synchronous way but asynchronous executed.

You can also use co_create/co_resume/co_yield interfaces to create asynchronous back-end service. These interface will give you more control of coroutines.

By libco copy-stack mode, you can easily build a back-end service support tens of millions of tcp connection.
***
### 简介
libco是微信后台大规模使用的c/c++协程库，2013年至今稳定运行在微信后台的数万台机器上。  

libco通过仅有的几个函数接口 co_create/co_resume/co_yield 再配合 co_poll，可以支持同步或者异步的写法，如线程库一样轻松。同时库里面提供了socket族函数的hook，使得后台逻辑服务几乎不用修改逻辑代码就可以完成异步化改造。

作者: sunnyxu(sunnyxu@tencent.com), leiffyli(leiffyli@tencent.com), dengoswei@gmail.com(dengoswei@tencent.com), sarlmolchen(sarlmolchen@tencent.com)

PS: **近期将开源PaxosStore，敬请期待。**

### libco的特性
- 无需侵入业务逻辑，把多进程、多线程服务改造成协程服务，并发能力得到百倍提升;
- 支持CGI框架，轻松构建web服务(New);
- 支持gethostbyname、mysqlclient、ssl等常用第三库(New);
- 可选的共享栈模式，单机轻松接入千万连接(New);
- 完善简洁的协程编程接口
 * 类pthread接口设计，通过co_create、co_resume等简单清晰接口即可完成协程的创建与恢复；
 * __thread的协程私有变量、协程间通信的协程信号量co_signal (New);
 * 语言级别的lambda实现，结合协程原地编写并执行后台异步任务 (New);
 * 基于epoll/kqueue实现的小而轻的网络框架，基于时间轮盘实现的高性能定时器;

### Build

```bash
$ cd /path/to/libco
$ make
```

or use cmake

```bash
$ cd /path/to/libco
$ mkdir build
$ cd build
$ cmake ..
$ make
```


