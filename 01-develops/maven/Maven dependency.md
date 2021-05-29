## Transitive Dependencies

There is no limit to the number of levels that dependencies can be gathered from. A problem arises only if a cyclic dependency is discovered.

With transitive dependencies, **the graph of included libraries can quickly grow quite large**. For this reason, there are additional features that limit which dependencies are included:



### Dependency mediation

**this determines what version of an artifact will be chosen** when multiple versions are encountered as dependencies. 

Maven picks the "**nearest definition**". 

That is, it uses the version of the closest dependency to your project in the tree of dependencies. You can **always guarantee a version by declaring it explicitly in your project's POM.** 

Note that if two dependency versions are at the same depth in the dependency tree, the first declaration wins.

"**nearest definition**" means that the version used will be the **closest one to your project** in the tree of dependencies. Consider this tree of dependencies:

```
  A
  ├── B
  │   └── C
  │       └── D 2.0
  └── E
      └── D 1.0
```

In text, dependencies for A, B, and C are defined as A -> B -> C -> D 2.0 and A -> E -> D 1.0, **then D 1.0 will be used when building A because the path from A to D through E is shorter.** 

**You could explicitly add a dependency to D 2.0 in A to force the use of D 2.0**, as shown here:

```
  A
  ├── B
  │   └── C
  │       └── D 2.0
  ├── E
  │   └── D 1.0
  │
  └── D 2.0      
```



### Dependency Scope

Dependency scope is used to **limit the transitivity of a dependency** and to determine when a dependency is included in a classpath.

There are 6 scopes:

- **compile**
  This is the default scope, used if none is specified. **Compile dependencies are available in all classpaths of a project**. Furthermore, those dependencies are **propagated to dependent projects**.
- **provided**
  This is much like `compile`, but **indicates you expect the JDK or a container to provide the dependency at runtime**. For example, when building a web application for the Java Enterprise Edition, you would set the dependency on the Servlet API and related Java EE APIs to scope `provided` because the web container provides those classes. A dependency with this scope is added to the classpath used for compilation and test, but not the runtime classpath. **It is not transitive.**
- **runtime**
  This scope indicates that the dependency is not required for compilation, but is for execution. Maven includes a dependency with this scope **in the runtime and test classpaths, but not the compile classpath.**
- **test**
  This scope indicates that the dependency is not required for normal use of the application, and is **only available for the test compilation and execution phases**. **This scope is not transitive**. Typically this scope is used for test libraries such as JUnit and Mockito. It is also used for non-test libraries such as Apache Commons IO if those libraries are used in unit tests (src/test/java) but not in the model code (src/main/java).
- **system**
  **This scope is similar to `provided` except that you have to provide the JAR which contains it explicitly**. The artifact is always available and is not looked up in a repository.
- **import**
  This scope is **only supported on a dependency of type `pom` in the `<dependencyManagement>` section**. **It indicates the dependency is to be replaced with the effective list of dependencies in the specified POM's `<dependencyManagement>` section**. Since they are replaced, dependencies with a scope of `import` do not actually participate in limiting the transitivity of a dependency.

### Dependency Management

The dependency management section is a mechanism for **centralizing dependency information.** 

When you have a set of projects that inherit from a common parent, it's possible to put all information about the dependency in the common POM and have simpler references to the artifacts in the child POMs. 



#### centralizing manage

Parent POM:

```xml
<project>
  ...
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>group-a</groupId>
        <artifactId>artifact-a</artifactId>
        <version>1.0</version>
 
        <exclusions>
          <exclusion>
            <groupId>group-c</groupId>
            <artifactId>excluded-artifact</artifactId>
          </exclusion>
        </exclusions>
 
      </dependency>
 
      <dependency>
        <groupId>group-c</groupId>
        <artifactId>artifact-b</artifactId>
        <version>1.0</version>
        <type>war</type>
        <scope>runtime</scope>
      </dependency>
 
      <dependency>
        <groupId>group-a</groupId>
        <artifactId>artifact-b</artifactId>
        <version>1.0</version>
        <type>bar</type>
        <scope>runtime</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
</project>
```

Then the two child POMs become much simpler:

```xml
<project>
  ...
  <dependencies>
    <dependency>
      <groupId>group-a</groupId>
      <artifactId>artifact-a</artifactId>
    </dependency>
 
    <dependency>
      <groupId>group-a</groupId>
      <artifactId>artifact-b</artifactId>
      <!-- This is not a jar dependency, so we must specify type. -->
      <type>bar</type>
    </dependency>
  </dependencies>
</project>
```

```xml
<project>
  ...
  <dependencies>
    <dependency>
      <groupId>group-c</groupId>
      <artifactId>artifact-b</artifactId>
      <!-- This is not a jar dependency, so we must specify type. -->
      <type>war</type>
    </dependency>
 
    <dependency>
      <groupId>group-a</groupId>
      <artifactId>artifact-b</artifactId>
      <!-- This is not a jar dependency, so we must specify type. -->
      <type>bar</type>
    </dependency>
  </dependencies>
</project>
```



#### control version

A second, and very important use of the dependency management section is to control the versions of artifacts used in transitive dependencies. As an example consider these projects:

A:

```xml
<project>
 <modelVersion>4.0.0</modelVersion>
 <groupId>maven</groupId>
 <artifactId>A</artifactId>
 <packaging>pom</packaging>
 <name>A</name>
 <version>1.0</version>
 <dependencyManagement>
   <dependencies>
     <dependency>
       <groupId>test</groupId>
       <artifactId>a</artifactId>
       <version>1.2</version>
     </dependency>
     <dependency>
       <groupId>test</groupId>
       <artifactId>b</artifactId>
       <version>1.0</version>
       <scope>compile</scope>
     </dependency>
     <dependency>
       <groupId>test</groupId>
       <artifactId>c</artifactId>
       <version>1.0</version>
       <scope>compile</scope>
     </dependency>
     <dependency>
       <groupId>test</groupId>
       <artifactId>d</artifactId>
       <version>1.2</version>
     </dependency>
   </dependencies>
 </dependencyManagement>
</project>
```

B:

```xml
<project>
  <parent>
    <artifactId>A</artifactId>
    <groupId>maven</groupId>
    <version>1.0</version>
  </parent>
  <modelVersion>4.0.0</modelVersion>
  <groupId>maven</groupId>
  <artifactId>B</artifactId>
  <packaging>pom</packaging>
  <name>B</name>
  <version>1.0</version>
 
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>test</groupId>
        <artifactId>d</artifactId>
        <version>1.0</version>
      </dependency>
    </dependencies>
  </dependencyManagement>
 
  <dependencies>
    <dependency>
      <groupId>test</groupId>
      <artifactId>a</artifactId>
      <version>1.0</version>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>test</groupId>
      <artifactId>c</artifactId>
      <scope>runtime</scope>
    </dependency>
  </dependencies>
</project>
```

When maven is run on project B, **version 1.0 of artifacts a, b, c, and d will be used regardless of the version specified in their POM**.

- a and c both are declared as dependencies of the project so version 1.0 is used **due to dependency mediation**. Both also have runtime scope since it is **directly specified.**
- b is defined in B's parent's dependency management section and since **dependency management takes precedence over dependency mediation** for transitive dependencies, version 1.0 will be selected should it be referenced in a or c's POM. b will also have compile scope.
- Finally, since d is specified in B's dependency management section, should d be a dependency (or transitive dependency) of a or c, version 1.0 will be chosen - again because **dependency management takes precedence over dependency mediation and also because the current POM's declaration takes precedence over its parent's declaration**.