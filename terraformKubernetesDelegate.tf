terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.31.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.12.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "${var.kubectl_config_context}"
}


#### INPUT VARIABLE SECTION ####

variable "harness_account_id" {
  type = string
  description = "Harness SAAS account id"
}

variable "harness_delegate_token" {
  type = string
  description = "Harness SAAS delegate token"
}

variable "delegate_name" {
  type = string
  description = "Delegate Name"
}


variable "delegate_namespace" {
  type = string
  description = "Delegate Namespace"
}

variable "kubectl_config_context" {
  type = string
  description = "Config context name inside the kubeconfig file"
}

#### DELEGATE NAMESPACE ####

resource "kubernetes_namespace" "delegatenamespace" {
  metadata {
    annotations = {
      name = ""
    }

    labels = {
      mylabel = ""
    }

    name = "${var.delegate_namespace}"
  }
}

#### DELEGATE ROLE BINDING ####

resource "kubernetes_cluster_role_binding" "delegateclusterrolebinding" {
  metadata {
    name = "harness-delegate-ng-cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "${var.delegate_namespace}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
}

#### DELEGATE SECRET ####

resource "kubernetes_secret" "delegatesecret" {
  metadata {
    name = "${var.delegate_name}-proxy"
    namespace = "${var.delegate_namespace}"
  }

  data = {
    PROXY_USER = ""
    PROXY_PASSWORD = ""
  }

  type = "Opaque"
}


#### DELEGATE STATEFULSET ####

resource "kubernetes_stateful_set" "delegatesatefulset" {
  metadata {
    annotations = {
    }

    labels = {
      "harness.io/name" = "${var.delegate_name}"
    }

    name = "${var.delegate_name}"
    namespace = "${var.delegate_namespace}"
  }

  spec {
    replicas = 2
    pod_management_policy = "Parallel"

    selector {
      match_labels = {
        "harness.io/name" = "${var.delegate_name}"
      }
    }

    service_name = ""

    template {
      metadata {
        labels = {
          "harness.io/name" = "${var.delegate_name}"
        }
        
      }

      spec {

        container {
          name              = "harness-delegate-instance"
          image             = "harness/delegate:latest"
          image_pull_policy = "Always"

         
          resources {
            limits = {
              cpu    = "0.5"
              memory = "2048Mi"
            }
            requests = {
              cpu    = "0.5"
              memory = "2048Mi"
            }
          }
           readiness_probe {
            exec {
              command = ["test","-s","delegate.log"]
            }

            initial_delay_seconds = 20
            period_seconds       = 10
          }

          liveness_probe {
            exec {
              command = ["bash","-c","'[[ -e /opt/harness-delegate/msg/data/watcher-data && $(($(date +%s000) - $(grep heartbeat /opt/harness-delegate/msg/data/watcher-data | cut -d : -f 2 | cut -d "," -f 1))) -lt 300000 ]]'"]
            }

            initial_delay_seconds = 240
            period_seconds       = 10
            failure_threshold      = 2
          }
         


          env {
              name = "JAVA_OPTS"
              value = "-Xms64M"
            }


          env {
              name = "ACCOUNT_ID"
              value = var.harness_account_id
            }
          
          env {
              name = "DELEGATE_TOKEN"
              value = var.harness_delegate_token
            }

          env {
           name = "MANAGER_HOST_AND_PORT"
           value = "https://app.harness.io/gratis"
           }
          env {
           name = "WATCHER_STORAGE_URL"
           value = "https://app.harness.io/public/free/freemium/watchers"
          }
          env{
           name = "WATCHER_CHECK_LOCATION"
           value = "current.version"
          }

          env{
           name = "DELEGATE_STORAGE_URL"
           value = "https://app.harness.io"
          }


          env{
           name = "REMOTE_WATCHER_URL_CDN"
           value = "https://app.harness.io/public/shared/watchers/builds"
          }
          env {
           name = "DELEGATE_CHECK_LOCATION"
           value = "delegatefree.txt"
          }

          env {
            name = "DEPLOY_MODE"
            value = "KUBERNETES"   
          }

          env {
            name = "INIT_SCRIPT"
            value = ""   
          }

          env {
            name = "DELEGATE_DESCRIPTION"
            value = ""   
          }

          env {
            name = "DELEGATE_TAGS"
            value = ""   
          }

          env {
            name = "NEXT_GEN"
            value = "true"   
          }

          env {
           name = "DELEGATE_NAME"
           value = var.delegate_name
          }
        env {
           name = "DELEGATE_PROFILE"
           value = "B3RBC7YQRFOcdnqYUz-8uA"
         }

         env {
           name = "DELEGATE_TYPE"
           value = "KUBERNETES"
         }

         env {
           name = "PROXY_HOST"
           value = ""
         }
         env {
           name = "PROXY_PORT"
           value = ""
         }
         env {
           name = "PROXY_SCHEME"
           value = ""
         }
         env {
           name = "NO_PROXY"
           value = ""
         }
         env {
           name = "PROXY_MANAGER"
           value = "true"
         }
         env {
           name = "PROXY_USER"
           value_from {
            secret_key_ref {
              name = "${var.delegate_name}-proxy"
              key = "PROXY_USER"
            }
           }
         }
         env {
          name = "PROXY_PASSWORD"
          value_from {
            secret_key_ref {
              name = "${var.delegate_name}-proxy"
              key = "PROXY_PASSWORD"
            }
          }
         }
         
         env {
          name = "CDN_URL"
          value = "https://app.harness.io"
         }
         env {
          name = "JRE_VERSION"
          value = "11.0.14"
         }
         env {
          name = "HELM3_PATH"
          value = ""
         }
         env {
          name = "HELM_PATH"
          value = ""
         }
      
         env {
          name = "KUSTOMIZE_PATH"
          value = ""
         }
    
         env {
          name = "KUBECTL_PATH"
          value = ""
         }
         env {
          name = "ENABlE_CE"
          value = "false"
         }
         env {
          name = "GRPC_SERVICE_ENABLED"
          value = "true"
         }
         env {
          name = "GRPC_SERVICE_CONNECTOR_PORT"
          value = "8080"
         }
         env {
          name = "CLIENT_TOOLS_DOWNLOAD_DISABLED"
          value = "false"
         }
         env {
          name = "DELEGATE_NAMESPACE"
          value_from {
            field_ref {
              field_path = "metadata.namespace"
            }
          }
         }

        
   
    }
    restart_policy = "Always"
  }
}
  }
}  

#### DELEGATE SERVICE ####

resource "kubernetes_service" "delegateservice" {
  metadata {
    name = "delegate-service"
    namespace = "${var.delegate_namespace}"

  }
  spec {
    selector = {
      "harness.io/name" = "${var.delegate_name}"
    }
  
    port {
      port = 8080
    }

    type = "ClusterIP"

    
      
  }
}
